$ErrorActionPreference = "Stop"

$envPath = Join-Path -Path "docker" -ChildPath ".env"
$examplePath = Join-Path -Path "docker" -ChildPath ".env.example"

if (-not (Test-Path $envPath)) {
  Copy-Item $examplePath $envPath
  Write-Host "Создан docker/.env. Отредактируйте пароли и перезапустите скрипт при необходимости." -ForegroundColor Yellow
}

Write-Host "Запуск MariaDB через Docker Compose..." -ForegroundColor Cyan

docker compose -f docker/compose.yml up -d

Write-Host "Проверка порта 3306..." -ForegroundColor Cyan
$portCheck = Test-NetConnection -ComputerName 127.0.0.1 -Port 3306
if (-not $portCheck.TcpTestSucceeded) {
  Write-Host "Порт 3306 недоступен. Проверьте Docker Desktop и контейнер db." -ForegroundColor Red
  exit 1
}

Write-Host "MariaDB запущена и слушает порт 3306." -ForegroundColor Green
