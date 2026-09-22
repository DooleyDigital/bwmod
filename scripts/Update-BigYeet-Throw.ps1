param(
    [Parameter(Mandatory = $true)][string]$CommonPath,
    [ValidateRange(0.05, 5.0)][double]$ForceMultiplier = 0.70
)

$ErrorActionPreference = 'Stop'

try {
    . $CommonPath
    Write-BigWalkHeader -Title 'BIGYEET THROW STRENGTH UPDATER'

    $enteredValue = Read-Host 'Enter throw multiplier, or press Enter for 0.70'
    if ($enteredValue) {
        $parsedValue = 0.0
        $parsed = [double]::TryParse(
            $enteredValue,
            [Globalization.NumberStyles]::Float,
            [Globalization.CultureInfo]::InvariantCulture,
            [ref]$parsedValue
        )

        if (-not $parsed -or $parsedValue -lt 0.05 -or $parsedValue -gt 5.0) {
            throw 'Enter a number from 0.05 through 5.0, such as 0.70 or 1.00.'
        }

        $ForceMultiplier = $parsedValue
    }

    Stop-BigWalkIfRunning
    $result = Set-BigYeetThrowMultiplier -ForceMultiplier $ForceMultiplier -CreateBackup

    Write-Host ''
    Write-Host '[OK] BigYeet throw strength updated' -ForegroundColor Green
    Write-Host "Game:       $($result.GameFolder)"
    Write-Host "Config:     $($result.ConfigFile)"
    if ($null -ne $result.OldValue) {
        Write-Host "Old value:  $($result.OldValue)"
    }
    else {
        Write-Host 'Old value:  Not previously configured'
    }
    Write-Host "New value:  $($result.NewValue)" -ForegroundColor Cyan
    if ($result.BackupFile) {
        Write-Host "Backup:     $($result.BackupFile)"
    }

    Write-Host ''
    Write-Host '0.35 is BigYeet''s original default. 0.70 is twice that force.' -ForegroundColor DarkGray
    exit 0
}
catch {
    Write-Host ''
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
