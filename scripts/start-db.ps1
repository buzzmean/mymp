$ErrorActionPreference = "Stop"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host "Skipping DB (no docker)" -ForegroundColor Yellow
  exit 0
}

$envPath = Join-Path -Path "docker" -ChildPath ".env"
$examplePath = Join-Path -Path "docker" -ChildPath ".env.example"

if (-not (Test-Path $envPath)) {
  Copy-Item $examplePath $envPath
  Write-Host "Created docker/.env. Edit passwords and rerun if needed." -ForegroundColor Yellow
}

Write-Host "Starting MariaDB with Docker Compose..." -ForegroundColor Cyan

docker compose -f docker/compose.yml up -d

Write-Host "Checking port 3306..." -ForegroundColor Cyan
$portCheck = Test-NetConnection -ComputerName 127.0.0.1 -Port 3306
if (-not $portCheck.TcpTestSucceeded) {
  Write-Host "Port 3306 is not reachable. Check Docker Desktop and db container." -ForegroundColor Red
  exit 1
}

Write-Host "MariaDB is running and listening on port 3306." -ForegroundColor Green
