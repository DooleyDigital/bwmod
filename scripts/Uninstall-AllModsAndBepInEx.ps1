param([Parameter(Mandatory = $true)][string]$CommonPath)

$ErrorActionPreference = 'Stop'

try {
    . $CommonPath
    Uninstall-AllBigWalkModsAndBepInEx
    exit 0
}
catch {
    Write-Host ''
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
