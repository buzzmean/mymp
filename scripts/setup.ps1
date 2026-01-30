$ErrorActionPreference = "Stop"

$runtimeDir = "runtime"
$fxDir = Join-Path $runtimeDir "fxserver"
$txDataDir = Join-Path $runtimeDir "txData"

New-Item -ItemType Directory -Path $fxDir -Force | Out-Null
New-Item -ItemType Directory -Path $txDataDir -Force | Out-Null

$baseUrl = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/"
Write-Host "Поиск рекомендуемого FXServer артефакта..." -ForegroundColor Cyan

$index = Invoke-WebRequest -UseBasicParsing $baseUrl
$recommended = [regex]::Matches($index.Content, 'href="(?<path>\d+-[^"]+)/"[^\n]*RECOMMENDED') | Select-Object -First 1
if (-not $recommended) {
  Write-Host "Не удалось найти рекомендованный артефакт на runtime.fivem.net" -ForegroundColor Red
  exit 1
}

$artifactPath = $recommended.Groups['path'].Value
$artifactUrl = "${baseUrl}${artifactPath}/server.zip"
$zipPath = Join-Path $runtimeDir "fxserver.zip"

Write-Host "Скачивание: $artifactUrl" -ForegroundColor Cyan
Invoke-WebRequest -UseBasicParsing $artifactUrl -OutFile $zipPath

Write-Host "Распаковка FXServer..." -ForegroundColor Cyan
if (Test-Path $fxDir) {
  Remove-Item -Recurse -Force $fxDir
}
New-Item -ItemType Directory -Path $fxDir -Force | Out-Null
Expand-Archive -Path $zipPath -DestinationPath $fxDir -Force

Remove-Item $zipPath -Force

Write-Host "FXServer установлен в $fxDir" -ForegroundColor Green
Write-Host "txAdmin данные будут храниться в $txDataDir" -ForegroundColor Green
