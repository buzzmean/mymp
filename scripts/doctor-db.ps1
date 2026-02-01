Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot ".."))
}

function Test-Port {
    param(
        [string]$Host,
        [int]$Port
    )
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $client.Connect($Host, $Port)
        $client.Close()
        return $true
    } catch {
        return $false
    }
}

$repoRoot = Get-RepoRoot
$runtimeRoot = Join-Path $repoRoot "runtime"
$logsDir = Join-Path $runtimeRoot "logs"
$pidFile = Join-Path $runtimeRoot "mariadb.pid"
$logFile = Join-Path $logsDir "mariadb.err"

$portOpen = Test-Port -Host "127.0.0.1" -Port 3306
if ($portOpen) {
    Write-Host "Port 3306: OPEN"
} else {
    Write-Host "Port 3306: CLOSED"
}

if (Test-Path $pidFile) {
    $pid = Get-Content -Path $pidFile -ErrorAction SilentlyContinue
    if ($pid) {
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($null -ne $process) {
            Write-Host "PID file: $pid (running)"
        } else {
            Write-Host "PID file: $pid (not running)"
        }
    } else {
        Write-Host "PID file exists but empty."
    }
} else {
    Write-Host "PID file not found."
}

if (Test-Path $logFile) {
    Write-Host "Last 30 lines of mariadb.err:"
    Get-Content -Path $logFile -Tail 30
} else {
    Write-Host "Log file not found at $logFile"
}
