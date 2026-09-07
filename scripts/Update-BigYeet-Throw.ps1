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

    $gameFolder = Find-BigWalkFolder
    $pluginsFolder = Join-Path $gameFolder 'BepInEx\plugins'
    $bigYeetDll = Get-ChildItem -LiteralPath $pluginsFolder -Filter 'BigYeet.dll' -File -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if (-not $bigYeetDll) {
        throw 'BigYeet is not installed. Install BigYeet before running this updater.'
    }

    Stop-BigWalkIfRunning

    $configFolder = Join-Path $gameFolder 'BepInEx\config'
    $configFile = Join-Path $configFolder 'BigYeet.cfg'
    New-Item -ItemType Directory -Path $configFolder -Force | Out-Null

    $backupFile = $null
    $lines = @()
    if (Test-Path -LiteralPath $configFile) {
        $backupFile = "$configFile.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $configFile -Destination $backupFile -Force
        $lines = @(Get-Content -LiteralPath $configFile -ErrorAction Stop)
    }

    $formattedValue = $ForceMultiplier.ToString(
        '0.00###',
        [Globalization.CultureInfo]::InvariantCulture
    )
    $replacement = "ForceMultiplier = $formattedValue"
    $updatedLines = New-Object 'System.Collections.Generic.List[string]'
    $insideThrowing = $false
    $throwingSectionFound = $false
    $forceKeyWritten = $false
    $oldValue = $null

    foreach ($line in $lines) {
        if ($line -match '^\s*\[([^]]+)\]\s*$') {
            if ($insideThrowing -and -not $forceKeyWritten) {
                $updatedLines.Add($replacement)
                $forceKeyWritten = $true
            }

            $insideThrowing = ($Matches[1] -ieq 'Throwing')
            if ($insideThrowing) {
                $throwingSectionFound = $true
            }

            $updatedLines.Add($line)
            continue
        }

        if ($insideThrowing -and $line -match '^\s*ForceMultiplier\s*=\s*(.*?)\s*$') {
            if ($null -eq $oldValue) {
                $oldValue = $Matches[1]
            }
            $updatedLines.Add($replacement)
            $forceKeyWritten = $true
            continue
        }

        $updatedLines.Add($line)
    }

    if ($insideThrowing -and -not $forceKeyWritten) {
        $updatedLines.Add($replacement)
        $forceKeyWritten = $true
    }

    if (-not $throwingSectionFound) {
        if ($updatedLines.Count -gt 0 -and $updatedLines[$updatedLines.Count - 1] -ne '') {
            $updatedLines.Add('')
        }
        $updatedLines.Add('[Throwing]')
        $updatedLines.Add($replacement)
    }

    $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($configFile, [string[]]$updatedLines, $utf8WithoutBom)

    Write-Host ''
    Write-Host '[OK] BigYeet throw strength updated' -ForegroundColor Green
    Write-Host "Game:       $gameFolder"
    Write-Host "Config:     $configFile"
    if ($oldValue) {
        Write-Host "Old value:  $oldValue"
    }
    else {
        Write-Host 'Old value:  Not previously configured'
    }
    Write-Host "New value:  $formattedValue" -ForegroundColor Cyan
    if ($backupFile) {
        Write-Host "Backup:     $backupFile"
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
