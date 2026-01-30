$ErrorActionPreference = "Stop"

$fxDir = Join-Path "runtime" "fxserver"
$exe = Join-Path $fxDir "FXServer.exe"

if (-not (Test-Path $exe)) {
  Write-Host "FXServer not found. Run scripts/setup.ps1 first." -ForegroundColor Red
  exit 1
}

Write-Host "Starting FXServer and txAdmin..." -ForegroundColor Cyan
Write-Host "" 
Write-Host "Open txAdmin in your browser:" -ForegroundColor Yellow
Write-Host "http://127.0.0.1:40120" -ForegroundColor Yellow
Write-Host "" 
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1) Get a key from https://keymaster.fivem.net" 
Write-Host "2) Choose recipe: Local file -> recipes/qbcore.yaml" 
Write-Host "3) If you run DB, enter credentials from docker/.env" 
Write-Host "" 

Start-Process -FilePath $exe -WorkingDirectory $fxDir -ArgumentList @(
  "+set", "txAdminPort", "40120",
  "+set", "txAdminHost", "0.0.0.0",
  "+set", "txAdminName", "mymp",
  "+set", "txAdminVerbose", "true"
)
