<#
.SYNOPSIS
  Adds JRiver Media Center folders, executables & processes to Windows Defender exclusions.

.DESCRIPTION
  powershell -ExecutionPolicy Bypass -File .\jriver-exclusions.ps1  
#>

# JRiver Media Center version to exclude
$Version = 34

function Add-ItemExclusion {
    param(
        [string]$Item,
        [ValidateSet('Path','Process')]$Type
    )
    try {
        if ($Type -eq 'Path') {
            Add-MpPreference -ExclusionPath $Item -ErrorAction Stop
        } else {
            Add-MpPreference -ExclusionProcess $Item -ErrorAction Stop
        }
        Write-Host "Added ${Type}: ${Item}"
    }
    catch {
        Write-Warning "Skipped/failed ${Type}: ${Item} - $_"
    }
}

# Build base dir & lists
$exeDir = "C:\Program Files\J River\Media Center $Version"
Write-Host "Configuring JRiver Media Center version $Version"

$folders = @(
    'C:\Program Files\J River',
    $exeDir,
    "$Env:APPDATA\J River",
    "$Env:APPDATA\J River\Media Center $Version"
)

$executables = @(
    "$exeDir\Media Editor.exe",
    "$exeDir\PackageInstaller.exe",
    "$exeDir\JRCrashHandler.exe",
    "$exeDir\JRMediaUninstall.exe",
    "$exeDir\JRService.exe",
    "$exeDir\JRWeb.exe",
    "$exeDir\JRWorker.exe",
    "$exeDir\MC$Version.exe",
    "$exeDir\Media Center $Version.exe",
    "C:\Windows\System32\MC$Version.exe",
    "C:\Windows\SysWOW64\MC$Version.exe"
)

$processes = @(
    "Media Center $Version.exe",
    "MC$Version.exe",
    'JRService.exe',
    'JRWorker.exe'
)

# Add exclusions
Write-Host "=== Adding folder exclusions ==="
$folders | ForEach-Object { Add-ItemExclusion -Item $_ -Type Path }

Write-Host "=== Adding file exclusions ==="
$executables | ForEach-Object { Add-ItemExclusion -Item $_ -Type Path }

Write-Host "=== Adding process exclusions ==="
($processes + ($executables | Split-Path -Leaf) | Sort-Object -Unique) |
    ForEach-Object { Add-ItemExclusion -Item $_ -Type Process }

# Summary
$pref = Get-MpPreference
Write-Host ''
Write-Host "=== Current Defender exclusion counts ==="
Write-Host ("  Paths    : {0}" -f $pref.ExclusionPath.Count)
Write-Host ("  Processes: {0}" -f $pref.ExclusionProcess.Count)
Write-Host ''