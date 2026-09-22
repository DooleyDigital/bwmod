param(
    [Parameter(Mandatory = $true)][string]$CommonPath,
    [Parameter(Mandatory = $true)][ValidateSet('Install', 'Uninstall')][string]$Action,
    [Parameter(Mandatory = $true)][string]$Mods
)

$ErrorActionPreference = 'Stop'

try {
    . $CommonPath

    $allowedMods = @('BigYeet', 'BigDart', 'BigTeleport', 'BigFirework', 'Madys_MiniMap')
    $selectedMods = @(
        $Mods.Split(',') |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ } |
            Select-Object -Unique
    )

    if ($selectedMods.Count -eq 0) {
        throw 'No mods were selected.'
    }

    foreach ($selectedMod in $selectedMods) {
        if ($selectedMod -notin $allowedMods) {
            throw "Unknown mod selection: $selectedMod"
        }
    }

    foreach ($selectedMod in $selectedMods) {
        if ($Action -eq 'Install') {
            switch ($selectedMod) {
                'BigYeet' {
                    Install-ThunderstoreMod -Name 'BigYeet' -Namespace 'hsiddaz' -DllName 'BigYeet.dll' -FallbackVersion '1.1.0'
                }
                'BigDart' {
                    Install-ThunderstoreMod -Name 'BigDart' -Namespace 'hsiddaz' -DllName 'BigDart.dll' -FallbackVersion '1.1.0'
                }
                'BigTeleport' {
                    Install-ThunderstoreMod -Name 'BigTeleport' -Namespace 'markviews' -DllName 'BigTeleport.dll' -FallbackVersion '1.0.2'
                }
                'BigFirework' {
                    Write-Host ''
                    Write-Host 'BigFirework requires ModSettingsMenu and BigWalkLocalizationAPI.' -ForegroundColor Yellow
                    Write-Host 'Installing or updating those support mods automatically...' -ForegroundColor Yellow

                    Install-ThunderstoreMod -Name 'BigWalkLocalizationAPI' -Namespace 'Ice_Box_Studio_BigWalk' -DllName 'BigWalkLocalizationAPI.dll' -FallbackVersion '1.1.0'
                    Install-ThunderstoreMod -Name 'ModSettingsMenu' -Namespace 'Ice_Box_Studio_BigWalk' -DllName 'ModSettingsMenu.dll' -FallbackVersion '1.1.2'
                    Install-ThunderstoreMod -Name 'BigFirework' -Namespace 'Trifocals' -DllName 'BigFirework.dll' -FallbackVersion '1.0.0'
                }
                'Madys_MiniMap' {
                    Install-ThunderstoreMod `
                        -Name 'Madys_MiniMap' `
                        -Namespace 'AdamMady' `
                        -DllName 'AdamMady_Minimap.dll' `
                        -FallbackVersion '1.1.2' `
                        -ReplacePluginPaths @('MapAssets', 'StbImageSharp.dll')
                }
            }
        }
        else {
            switch ($selectedMod) {
                'BigYeet' {
                    Uninstall-BigWalkMod -Name 'BigYeet' -DllName 'BigYeet.dll'
                }
                'BigDart' {
                    Uninstall-BigWalkMod -Name 'BigDart' -DllName 'BigDart.dll'
                }
                'BigTeleport' {
                    Uninstall-BigWalkMod -Name 'BigTeleport' -DllName 'BigTeleport.dll'
                }
                'BigFirework' {
                    Uninstall-BigWalkMod -Name 'BigFirework' -DllName 'BigFirework.dll'
                }
                'Madys_MiniMap' {
                    Uninstall-BigWalkMod `
                        -Name 'Madys_MiniMap' `
                        -DllName 'AdamMady_Minimap.dll' `
                        -AdditionalPluginPaths @('MapAssets', 'StbImageSharp.dll') `
                        -ConfigPatterns @('*AdamMady*Minimap*', '*Mady*MiniMap*')
                }
            }
        }
    }

    Write-Host ''
    Write-Host "[OK] Selected mod $($Action.ToLower()) actions completed" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ''
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
