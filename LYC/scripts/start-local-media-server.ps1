$ErrorActionPreference = 'Stop'

$serverScript = 'D:\Codex\LYC\scripts\local-media-server.js'
$lanIp = (
  Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' } |
  Sort-Object InterfaceMetric |
  Select-Object -First 1 -ExpandProperty IPAddress
)

try {
  $health = Invoke-WebRequest -Uri 'http://127.0.0.1:8123/health' -UseBasicParsing -TimeoutSec 2
  if ($health.StatusCode -eq 200) {
    Write-Output 'Local media server is already running.'
    if ($lanIp) {
      Write-Output ('LAN audio base URL: http://{0}:8123' -f $lanIp)
    }
    exit 0
  }
} catch {
}

Start-Process -FilePath node -ArgumentList $serverScript -WorkingDirectory 'D:\Codex\LYC'
Start-Sleep -Seconds 2

$result = Invoke-WebRequest -Uri 'http://127.0.0.1:8123/health' -UseBasicParsing -TimeoutSec 5
Write-Output $result.Content
if ($lanIp) {
  Write-Output ('LAN audio base URL: http://{0}:8123' -f $lanIp)
}
