$ErrorActionPreference = "Stop"

$fxDir = Join-Path "runtime" "fxserver"
$exe = Join-Path $fxDir "FXServer.exe"

if (-not (Test-Path $exe)) {
  Write-Host "FXServer не найден. Запустите сначала scripts/setup.ps1" -ForegroundColor Red
  exit 1
}

Write-Host "Запуск FXServer и txAdmin..." -ForegroundColor Cyan
Write-Host "" 
Write-Host "Дальше в txAdmin:" -ForegroundColor Yellow
Write-Host "1) Получите ключ: https://keymaster.fivem.net" 
Write-Host "2) Выберите рецепт: Local file -> recipes/qbcore.yaml" 
Write-Host "3) Введите доступы БД из docker/.env" 
Write-Host "" 

Start-Process -FilePath $exe -WorkingDirectory $fxDir -ArgumentList @(
  "+set", "txAdminPort", "40120",
  "+set", "txAdminHost", "0.0.0.0",
  "+set", "txAdminName", "mymp",
  "+set", "txAdminVerbose", "true"
)
