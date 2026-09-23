param(
    [Parameter(Mandatory = $true)][string]$CommonPath,
    [Parameter(Mandatory = $true)][ValidateSet('Install', 'Uninstall')][string]$Action,
    [Parameter(Mandatory = $true)][string]$Mods
)

$ErrorActionPreference = 'Stop'

try {
    . $CommonPath

    $allowedMods = @(
        'BigYeet', 'BigDart', 'BigTeleport', 'BigFirework', 'Madys_MiniMap',
        'NoClip', 'Better_Trains', 'QuickBelt', 'Item_Debug', 'Big_Run',
        'MapParachute', 'TeleportToPlayer', 'BigBack', 'Madys_HideNSeek',
        'Big_Person_View'
    )
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
                    $throwConfig = Set-BigYeetThrowMultiplier -ForceMultiplier 0.70 -CreateBackup
                    Write-Host "[OK] BigYeet throw multiplier set to $($throwConfig.NewValue)" -ForegroundColor Green
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
                'NoClip' {
                    Install-ThunderstoreMod -Name 'NoClip' -Namespace 'jangles' -DllName 'BigWalk.NoClip.dll' -FallbackVersion '1.0.4'
                }
                'Better_Trains' {
                    Install-ThunderstoreMod -Name 'Better_Trains' -Namespace 'BayTurtleKing' -DllName 'BetterTrain.dll' -FallbackVersion '1.0.1'
                }
                'QuickBelt' {
                    Install-ThunderstoreMod -Name 'QuickBelt' -Namespace 'hsiddaz' -DllName 'QuickBelt.dll' -FallbackVersion '1.0.1'
                }
                'Item_Debug' {
                    Install-ThunderstoreMod -Name 'Item_Debug' -Namespace 'SixSevenBrigade' -DllName 'GearDebug.dll' -FallbackVersion '1.1.4'
                }
                'Big_Run' {
                    Install-ThunderstoreMod -Name 'Big_Run' -Namespace 'BayTurtleKing' -DllName 'BigRun.dll' -FallbackVersion '1.0.3'
                }
                'MapParachute' {
                    Install-ThunderstoreMod -Name 'MapParachute' -Namespace 'gogogadgetjustice' -DllName 'Parachute Map.dll' -FallbackVersion '1.0.0'
                }
                'TeleportToPlayer' {
                    Install-ThunderstoreMod -Name 'TeleportToPlayer' -Namespace 'YonahG0y' -DllName 'TeleportToPlayer.dll' -FallbackVersion '0.2.0'
                }
                'BigBack' {
                    Write-Host ''
                    Write-Host 'BigBack requires gugger Core.' -ForegroundColor Yellow
                    Write-Host 'Installing or updating that support mod automatically...' -ForegroundColor Yellow
                    Install-ThunderstoreMod -Name 'Core' -Namespace 'gugger' -DllName 'smolMods.Core.dll' -FallbackVersion '1.0.10'
                    Install-ThunderstoreMod -Name 'BigBack' -Namespace 'gugger' -DllName 'smolMods.BigBack.dll' -FallbackVersion '1.0.1'
                }
                'Madys_HideNSeek' {
                    Install-ThunderstoreMod -Name 'Madys_HideNSeek' -Namespace 'AdamMady' -DllName 'Madys_HideNSeek.dll' -FallbackVersion '1.0.1'
                }
                'Big_Person_View' {
                    Install-ThunderstoreMod -Name 'Big_Person_View' -Namespace 'SixSevenBrigade' -DllName 'ThirdPerson.dll' -FallbackVersion '1.4.0'
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
                'NoClip' {
                    Uninstall-BigWalkMod -Name 'NoClip' -DllName 'BigWalk.NoClip.dll'
                }
                'Better_Trains' {
                    Uninstall-BigWalkMod -Name 'Better_Trains' -DllName 'BetterTrain.dll' -ConfigPatterns @('*Better*Train*')
                }
                'QuickBelt' {
                    Uninstall-BigWalkMod -Name 'QuickBelt' -DllName 'QuickBelt.dll'
                }
                'Item_Debug' {
                    Uninstall-BigWalkMod -Name 'Item_Debug' -DllName 'GearDebug.dll' -ConfigPatterns @('*geardebug*', '*Item*Debug*')
                }
                'Big_Run' {
                    Uninstall-BigWalkMod -Name 'Big_Run' -DllName 'BigRun.dll' -ConfigPatterns @('*BigRun*', '*Big_Run*')
                }
                'MapParachute' {
                    Uninstall-BigWalkMod -Name 'MapParachute' -DllName 'Parachute Map.dll' -ConfigPatterns @('*parachute*')
                }
                'TeleportToPlayer' {
                    Uninstall-BigWalkMod -Name 'TeleportToPlayer' -DllName 'TeleportToPlayer.dll'
                }
                'BigBack' {
                    Uninstall-BigWalkMod -Name 'BigBack' -DllName 'smolMods.BigBack.dll'
                }
                'Madys_HideNSeek' {
                    Uninstall-BigWalkMod -Name 'Madys_HideNSeek' -DllName 'Madys_HideNSeek.dll'
                }
                'Big_Person_View' {
                    Uninstall-BigWalkMod -Name 'Big_Person_View' -DllName 'ThirdPerson.dll' -ConfigPatterns @('*bigwalk*thirdperson*', '*BigPersonView*')
                }
            }
        }
    }

    $controls = Write-BigWalkControlsNote
    Write-Host ''
    Write-Host "[OK] Controls note updated: $($controls.NotePath)" -ForegroundColor Green
    Write-Host "[OK] Desktop shortcut updated: $($controls.ShortcutPath)" -ForegroundColor Green
    Write-Host ''
    Write-Host "[OK] Selected mod $($Action.ToLower()) actions completed" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ''
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
