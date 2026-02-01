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

function Wait-ForPort {
    param(
        [string]$Host,
        [int]$Port,
        [int]$TimeoutSeconds = 25
    )
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        try {
            $client = New-Object System.Net.Sockets.TcpClient
            $client.Connect($Host, $Port)
            if ($client.Connected) {
                $client.Close()
                return $true
            }
        } catch {
        }
        Start-Sleep -Seconds 1
    }
    return $false
}

function New-RandomPassword {
    param([int]$Length = 16)
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    $bytes = New-Object byte[]($Length)
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $result = New-Object System.Text.StringBuilder
    foreach ($b in $bytes) {
        [void]$result.Append($chars[$b % $chars.Length])
    }
    return $result.ToString()
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
$dataDir = Join-Path $runtimeRoot "mariadb-data"
$logsDir = Join-Path $runtimeRoot "logs"
$envFile = Join-Path $runtimeRoot "mariadb.env"
$pidFile = Join-Path $runtimeRoot "mariadb.pid"

$baseDir = Get-MariaDbBaseDir -MariaDbRoot $mariadbRoot
$configPath = Join-Path $mariadbRoot "my.ini"
$mariadbd = Join-Path $baseDir "bin\mariadbd.exe"
$client = Join-Path $baseDir "bin\mariadb.exe"
if (-not (Test-Path $client)) {
    $client = Join-Path $baseDir "bin\mysql.exe"
}

if (-not (Test-Path $mariadbd)) {
    throw "mariadbd.exe not found. Run scripts/setup-mariadb-portable.ps1 first."
}

if (-not (Test-Path $configPath)) {
    throw "Config not found at $configPath. Run scripts/setup-mariadb-portable.ps1 first."
}

if (-not (Test-Path $envFile)) {
    $generatedPassword = New-RandomPassword
    $envContent = @(
        "MARIADB_ROOT_PASSWORD=",
        "MARIADB_DATABASE=qbcore",
        "MARIADB_USER=qbcore",
        "MARIADB_PASSWORD=$generatedPassword"
    )
    $envContent | Set-Content -Path $envFile -Encoding ASCII
    Write-Warning "MariaDB root password is empty for local development. Update runtime/mariadb.env if you want to set one."
}

$envData = Read-EnvFile -Path $envFile
$rootPassword = $envData['MARIADB_ROOT_PASSWORD']
$databaseName = $envData['MARIADB_DATABASE']
$dbUser = $envData['MARIADB_USER']
$dbPassword = $envData['MARIADB_PASSWORD']

if ([string]::IsNullOrWhiteSpace($databaseName)) {
    $databaseName = "qbcore"
}
if ([string]::IsNullOrWhiteSpace($dbUser)) {
    $dbUser = "qbcore"
}
if ([string]::IsNullOrWhiteSpace($dbPassword)) {
    $dbPassword = New-RandomPassword
}

if (Test-Path $pidFile) {
    $existingPid = Get-Content -Path $pidFile -ErrorAction SilentlyContinue
    if ($existingPid) {
        $existingProcess = Get-Process -Id $existingPid -ErrorAction SilentlyContinue
        if ($null -ne $existingProcess) {
            Write-Host "MariaDB appears to be running with PID $existingPid"
            exit 0
        }
    }
}

Write-Host "Starting MariaDB..."
$process = Start-Process -FilePath $mariadbd -ArgumentList @("--defaults-file=$configPath", "--console") -PassThru
$process.Id | Set-Content -Path $pidFile -Encoding ASCII

if (-not (Wait-ForPort -Host "127.0.0.1" -Port 3306 -TimeoutSeconds 30)) {
    throw "MariaDB did not start listening on 127.0.0.1:3306 within timeout."
}

if (-not (Test-Path $client)) {
    throw "MariaDB client not found at $client"
}

$sql = @(
    "CREATE DATABASE IF NOT EXISTS $databaseName CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;",
    "CREATE USER IF NOT EXISTS '$dbUser'@'localhost' IDENTIFIED BY '$dbPassword';",
    "GRANT ALL PRIVILEGES ON $databaseName.* TO '$dbUser'@'localhost';",
    "FLUSH PRIVILEGES;"
) -join " "

$clientArgs = @("--protocol=TCP", "-h", "127.0.0.1", "-P", "3306", "-u", "root")
if (-not [string]::IsNullOrWhiteSpace($rootPassword)) {
    $clientArgs += "-p$rootPassword"
}
$clientArgs += "--execute=$sql"

& $client @clientArgs

Write-Host "MariaDB is running. PID saved to $pidFile"
