param(
    [switch]$SkipAnalyze,
    [switch]$SkipTest,
    [switch]$SkipPubGet
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$androidDir = Join-Path $repoRoot "android"
$outputDir = Join-Path $repoRoot "build\app\outputs\flutter-apk"

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host "==> $Name"
    & $Action
}

function Get-AppVersion {
    $versionLine = Select-String -Path (Join-Path $repoRoot "pubspec.yaml") -Pattern "^version:\s*(.+)$" | Select-Object -First 1
    if (-not $versionLine) {
        throw "Could not find version in pubspec.yaml."
    }

    return $versionLine.Matches[0].Groups[1].Value.Trim()
}

function Stop-GradleDaemons {
    $gradleWrapper = Join-Path $androidDir "gradlew.bat"
    if (Test-Path $gradleWrapper) {
        Push-Location $androidDir
        try {
            & .\gradlew.bat --stop | Out-Host
        } finally {
            Pop-Location
        }
    }

    $daemonPids = Get-CimInstance Win32_Process |
        Where-Object {
            $_.Name -eq "java.exe" -and
            $_.CommandLine -like "*GradleDaemon*"
        } |
        Select-Object -ExpandProperty ProcessId

    foreach ($daemonPid in $daemonPids) {
        Stop-Process -Id $daemonPid -Force -ErrorAction SilentlyContinue
    }
}

Invoke-Step -Name "Preparing Android release build" -Action {
    Write-Host "Repo root: $repoRoot"
    Write-Host "Output dir: $outputDir"
}

if (-not $SkipPubGet) {
    Invoke-Step -Name "Running flutter pub get" -Action {
        Push-Location $repoRoot
        try {
            & flutter pub get
            if ($LASTEXITCODE -ne 0) {
                throw "flutter pub get failed."
            }
        } finally {
            Pop-Location
        }
    }
}

if (-not $SkipAnalyze) {
    Invoke-Step -Name "Running flutter analyze" -Action {
        Push-Location $repoRoot
        try {
            & flutter analyze --no-pub
            if ($LASTEXITCODE -ne 0) {
                throw "flutter analyze failed."
            }
        } finally {
            Pop-Location
        }
    }
}

if (-not $SkipTest) {
    Invoke-Step -Name "Running flutter test" -Action {
        Push-Location $repoRoot
        try {
            & flutter test --no-pub
            if ($LASTEXITCODE -ne 0) {
                throw "flutter test failed."
            }
        } finally {
            Pop-Location
        }
    }
}

Invoke-Step -Name "Stopping Gradle daemons" -Action {
    Stop-GradleDaemons
}

Invoke-Step -Name "Building release APKs" -Action {
        Push-Location $repoRoot
        try {
            $env:ORG_GRADLE_PROJECT_kotlin_incremental = "false"
            & flutter build apk --no-pub --release --split-per-abi --tree-shake-icons
            if ($LASTEXITCODE -ne 0) {
                throw "flutter build apk failed."
            }
    } finally {
        Remove-Item Env:ORG_GRADLE_PROJECT_kotlin_incremental -ErrorAction SilentlyContinue
        Pop-Location
    }
}

Invoke-Step -Name "Creating timestamped artifacts" -Action {
    $version = Get-AppVersion
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

    $artifactMap = @(
        @{ Source = "app-arm64-v8a-release.apk"; Abi = "arm64-v8a" },
        @{ Source = "app-armeabi-v7a-release.apk"; Abi = "armeabi-v7a" },
        @{ Source = "app-x86_64-release.apk"; Abi = "x86_64" }
    )

    foreach ($artifact in $artifactMap) {
        $sourcePath = Join-Path $outputDir $artifact.Source
        if (-not (Test-Path $sourcePath)) {
            throw "Missing expected APK: $sourcePath"
        }

        $targetName = "codex-one-v$version-ts$timestamp-$($artifact.Abi)-release.apk"
        $targetPath = Join-Path $outputDir $targetName
        Copy-Item $sourcePath $targetPath -Force
    }

    $artifacts = Get-ChildItem $outputDir -Filter "codex-one-v$version-ts$timestamp-*-release.apk" |
        Sort-Object Name

    Write-Host ""
    Write-Host "Generated artifacts:"
    foreach ($artifact in $artifacts) {
        $sizeMb = [math]::Round($artifact.Length / 1MB, 2)
        Write-Host " - $($artifact.Name) ($sizeMb MB)"
    }
}
