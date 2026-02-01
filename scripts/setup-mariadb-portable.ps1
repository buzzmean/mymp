Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot ".."))
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Get-StringValues {
    param([object]$InputObject)
    $values = @()
    if ($null -eq $InputObject) {
        return $values
    }
    if ($InputObject -is [string]) {
        return @($InputObject)
    }
    if ($InputObject -is [System.Collections.IDictionary]) {
        foreach ($key in $InputObject.Keys) {
            $values += Get-StringValues $InputObject[$key]
        }
        return $values
    }
    if ($InputObject -is [System.Collections.IEnumerable]) {
        foreach ($item in $InputObject) {
            $values += Get-StringValues $item
        }
        return $values
    }
    $props = $InputObject.PSObject.Properties
    foreach ($prop in $props) {
        $values += Get-StringValues $prop.Value
    }
    return $values
}

function Get-MariaDbZipUrl {
    param([string]$PreferredSeries)

    $apiUrl = "https://downloads.mariadb.org/rest-api/mariadb/$PreferredSeries/"
    try {
        $api = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
        $strings = Get-StringValues $api
        $zipLinks = $strings | Where-Object { $_ -match 'winx64\.zip$' }
        $zipLinks = $zipLinks | Where-Object { $_ -match '^https?://' }
        if ($zipLinks.Count -gt 0) {
            return $zipLinks[0]
        }
    } catch {
        Write-Host "Failed to query REST API: $($_.Exception.Message)"
    }

    $indexUrl = "https://downloads.mariadb.org/mariadb/$PreferredSeries/"
    try {
        $index = Invoke-WebRequest -Uri $indexUrl -UseBasicParsing
        $absoluteMatch = [regex]::Match($index.Content, 'https?://[^"\s]+mariadb-[0-9\.]+-winx64\.zip')
        if ($absoluteMatch.Success) {
            return $absoluteMatch.Value
        }
        $relativeMatch = [regex]::Match($index.Content, 'winx64-packages/[^"\s]+mariadb-[0-9\.]+-winx64\.zip')
        if ($relativeMatch.Success) {
            return "https://downloads.mariadb.org/mariadb/$PreferredSeries/$($relativeMatch.Value)"
        }
        $simpleMatch = [regex]::Match($index.Content, 'mariadb-[0-9\.]+-winx64\.zip')
        if ($simpleMatch.Success) {
            return "https://downloads.mariadb.org/mariadb/$PreferredSeries/$($simpleMatch.Value)"
        }
    } catch {
        Write-Host "Failed to query download page: $($_.Exception.Message)"
    }

    throw "Could not find MariaDB ZIP download URL. Please set -DownloadUrl manually."
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

param(
    [string]$PreferredSeries = "11.4",
    [string]$DownloadUrl = ""
)

$repoRoot = Get-RepoRoot
$runtimeRoot = Join-Path $repoRoot "runtime"
$downloadsDir = Join-Path $runtimeRoot "downloads"
$mariadbRoot = Join-Path $runtimeRoot "mariadb"
$dataDir = Join-Path $runtimeRoot "mariadb-data"
$logsDir = Join-Path $runtimeRoot "logs"

Ensure-Directory $runtimeRoot
Ensure-Directory $downloadsDir
Ensure-Directory $mariadbRoot
Ensure-Directory $dataDir
Ensure-Directory $logsDir

if (-not (Test-Path (Join-Path $mariadbRoot "bin"))) {
    if ([string]::IsNullOrWhiteSpace($DownloadUrl)) {
        $DownloadUrl = Get-MariaDbZipUrl -PreferredSeries $PreferredSeries
    }
    Write-Host "Downloading MariaDB from $DownloadUrl"
    $zipName = Split-Path $DownloadUrl -Leaf
    $zipPath = Join-Path $downloadsDir $zipName
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $mariadbRoot -Force
}

$baseDir = Get-MariaDbBaseDir -MariaDbRoot $mariadbRoot
$installDb = Join-Path $baseDir "bin\mariadb-install-db.exe"
if (-not (Test-Path $installDb)) {
    throw "mariadb-install-db.exe not found at $installDb"
}

Ensure-Directory $dataDir
Write-Host "Initializing data directory at $dataDir"
& $installDb "--datadir=$dataDir" "--basedir=$baseDir"

$absoluteBase = [System.IO.Path]::GetFullPath($baseDir)
$absoluteData = [System.IO.Path]::GetFullPath($dataDir)
$absoluteLogs = [System.IO.Path]::GetFullPath($logsDir)

$configPath = Join-Path $mariadbRoot "my.ini"
$configContent = @(
    "[mysqld]",
    "basedir=$absoluteBase",
    "datadir=$absoluteData",
    "bind-address=127.0.0.1",
    "port=3306",
    "character-set-server=utf8mb4",
    "collation-server=utf8mb4_unicode_ci",
    "skip-name-resolve",
    "max_connections=50",
    "sql_mode=",
    "log_error=$absoluteLogs\\mariadb.err"
)
$configContent | Set-Content -Path $configPath -Encoding ASCII

Write-Host "MariaDB portable setup complete. Config at $configPath"
