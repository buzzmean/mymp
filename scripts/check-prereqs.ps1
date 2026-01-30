$ErrorActionPreference = "Stop"

Write-Host "Checking prerequisites..." -ForegroundColor Cyan

$missingRequired = @()
$missingOptional = @()

# PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
  $missingRequired += "PowerShell 5+"
}

# Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  $missingRequired += "Git"
}

# Internet
$internetOk = $false
try {
  $internetOk = Test-Connection -ComputerName 1.1.1.1 -Count 1 -Quiet
} catch {
  $internetOk = $false
}
if (-not $internetOk) {
  $missingRequired += "Internet access"
}

# Docker (optional)
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  $missingOptional += "Docker Desktop"
}

# 7-Zip (optional)
if (-not (Get-Command 7z -ErrorAction SilentlyContinue)) {
  $missingOptional += "7-Zip"
}

if ($missingOptional.Count -gt 0) {
  Write-Host "Optional missing:" -ForegroundColor Yellow
  $missingOptional | ForEach-Object { Write-Host " - $_" }
}

if ($missingRequired.Count -gt 0) {
  Write-Host "Required missing:" -ForegroundColor Red
  $missingRequired | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host "All required prerequisites are available." -ForegroundColor Green
