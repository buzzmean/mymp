Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot ".."))
}

function Get-MariaDbBaseDir {
    param([string]$MariaDbRoot)
    $binPath = Join-Path $MariaDbRoot "bin"
    if (Test-Path $binPath) {
        return $MariaDbRoot
    }
    $child = Get-ChildItem -Path $MariaDbRoot -Directory | Where-Object { Test-Path (Join-Path $_.FullName "bin") } | Select-Object -First 1
    if ($null -ne $child) {
        return $child.FullName
    }
    throw "MariaDB bin folder not found under $MariaDbRoot"
}

function Read-EnvFile {
    param([string]$Path)
    $result = @{}
    if (-not (Test-Path $Path)) {
        return $result
    }
    $lines = Get-Content -Path $Path
    foreach ($line in $lines) {
        if ($line -match '^\s*#') {
            continue
        }
        if ($line -match '^(?<key>[^=]+)=(?<value>.*)$') {
            $result[$matches['key']] = $matches['value']
        }
    }
    return $result
}

$repoRoot = Get-RepoRoot
$runtimeRoot = Join-Path $repoRoot "runtime"
$mariadbRoot = Join-Path $runtimeRoot "mariadb"
$envFile = Join-Path $runtimeRoot "mariadb.env"
$pidFile = Join-Path $runtimeRoot "mariadb.pid"

$baseDir = Get-MariaDbBaseDir -MariaDbRoot $mariadbRoot
$admin = Join-Path $baseDir "bin\mariadb-admin.exe"
if (-not (Test-Path $admin)) {
    $admin = Join-Path $baseDir "bin\mysqladmin.exe"
}

$envData = Read-EnvFile -Path $envFile
$rootPassword = $envData['MARIADB_ROOT_PASSWORD']

$shutdownSucceeded = $false
if (Test-Path $admin) {
    $adminArgs = @("-h", "127.0.0.1", "-P", "3306", "-u", "root")
    if (-not [string]::IsNullOrWhiteSpace($rootPassword)) {
        $adminArgs += "-p$rootPassword"
    }
    $adminArgs += "shutdown"
    try {
        & $admin @adminArgs
        $shutdownSucceeded = $true
        Write-Host "MariaDB shutdown command sent."
    } catch {
        Write-Host "Shutdown command failed: $($_.Exception.Message)"
    }
}

if (-not $shutdownSucceeded -and (Test-Path $pidFile)) {
    $pid = Get-Content -Path $pidFile -ErrorAction SilentlyContinue
    if ($pid) {
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($null -ne $process) {
            Stop-Process -Id $pid -Force
            Write-Host "MariaDB process $pid stopped."
            $shutdownSucceeded = $true
        }
    }
}

if (Test-Path $pidFile) {
    Remove-Item $pidFile -ErrorAction SilentlyContinue
}

if (-not $shutdownSucceeded) {
    Write-Host "MariaDB was not running or could not be stopped."
}
