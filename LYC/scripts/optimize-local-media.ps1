$ErrorActionPreference = 'Stop'

$root = 'D:\Codex\LYC\media\processed'
$minSizeBytes = 1MB

function Get-FfmpegPath {
  $command = Get-Command ffmpeg -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $candidates = @(
    'C:\Users\NINGMEI\AppData\Local\Microsoft\WinGet\Packages'
    'C:\Program Files'
    'C:\Program Files (x86)'
  )

  foreach ($candidateRoot in $candidates) {
    if (-not (Test-Path $candidateRoot)) {
      continue
    }

    $match = Get-ChildItem -Path $candidateRoot -Recurse -Filter ffmpeg.exe -ErrorAction SilentlyContinue |
      Select-Object -First 1 -ExpandProperty FullName

    if ($match) {
      return $match
    }
  }

  return $null
}

function Format-SizeKB {
  param([long]$Bytes)
  return [math]::Round($Bytes / 1KB, 1)
}

function Optimize-File {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$File
  )

  $tempPath = Join-Path $File.DirectoryName ($File.BaseName + '.optimized' + $File.Extension)
  if (Test-Path $tempPath) {
    Remove-Item -LiteralPath $tempPath -Force
  }

  $beforeBytes = $File.Length
  $ffmpegArgs = @('-y', '-i', $File.FullName, '-vn')

  switch ($File.Extension.ToLowerInvariant()) {
    '.mp3' {
      $ffmpegArgs += @('-ac', '1', '-ar', '32000', '-codec:a', 'libmp3lame', '-b:a', '64k', $tempPath)
    }
    '.m4a' {
      $ffmpegArgs += @('-ac', '1', '-ar', '24000', '-codec:a', 'aac', '-b:a', '48k', '-movflags', '+faststart', $tempPath)
    }
    default {
      return
    }
  }

  & $script:ffmpegPath @ffmpegArgs | Out-Null

  if (-not (Test-Path $tempPath)) {
    throw "Optimization failed for $($File.FullName)"
  }

  Move-Item -LiteralPath $tempPath -Destination $File.FullName -Force
  $afterBytes = (Get-Item -LiteralPath $File.FullName).Length

  [PSCustomObject]@{
    File = $File.Name
    BeforeKB = Format-SizeKB $beforeBytes
    AfterKB = Format-SizeKB $afterBytes
    SavedKB = Format-SizeKB ($beforeBytes - $afterBytes)
  }
}

if (-not $script:ffmpegPath) {
  $script:ffmpegPath = Get-FfmpegPath
}

if (-not $script:ffmpegPath) {
  throw 'ffmpeg is not installed or not available in PATH.'
}

$targets = Get-ChildItem -LiteralPath $root -Recurse -File |
  Where-Object {
    $_.Length -ge $minSizeBytes -and @('.mp3', '.m4a') -contains $_.Extension.ToLowerInvariant()
  } |
  Sort-Object Length -Descending

if (-not $targets) {
  Write-Output 'No media files need optimization.'
  exit 0
}

$results = foreach ($file in $targets) {
  Optimize-File -File $file
}

$results | Format-Table -AutoSize
