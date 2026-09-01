param([Parameter(Mandatory = $true)][string]$CommonPath)

$ErrorActionPreference = 'Stop'

try {
    . $CommonPath
    Install-ThunderstoreMod -Name 'BigDart' -Namespace 'hsiddaz' -DllName 'BigDart.dll' -FallbackVersion '1.1.0'
    exit 0
}
catch {
    Write-Host ''
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
