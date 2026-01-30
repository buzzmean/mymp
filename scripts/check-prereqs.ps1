$ErrorActionPreference = "Stop"

Write-Host "Проверка зависимостей..." -ForegroundColor Cyan

$missing = @()

# PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
  $missing += "PowerShell 5+"
}

# Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  $missing += "Docker Desktop"
}

# 7-Zip
if (-not (Get-Command 7z -ErrorAction SilentlyContinue)) {
  $missing += "7-Zip"
}

# Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  $missing += "Git"
}

if ($missing.Count -gt 0) {
  Write-Host "Не найдены компоненты:" -ForegroundColor Yellow
  $missing | ForEach-Object { Write-Host " - $_" }
  Write-Host "" 
  Write-Host "Установите:" -ForegroundColor Yellow
  Write-Host "- PowerShell: https://learn.microsoft.com/powershell/" 
  Write-Host "- Docker Desktop: https://www.docker.com/products/docker-desktop/" 
  Write-Host "- 7-Zip: https://www.7-zip.org/" 
  Write-Host "- Git: https://git-scm.com/downloads" 
  exit 1
}

Write-Host "Все зависимости найдены." -ForegroundColor Green
