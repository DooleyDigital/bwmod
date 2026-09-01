Set-StrictMode -Version 2.0

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$script:BigWalkAppId = '1478500'
$script:BepInExVersion = '6.0.0-be.785+6abdba4'
$script:BepInExUrl = 'https://builds.bepinex.dev/projects/bepinex_be/785/BepInEx-Unity.IL2CPP-win-x64-6.0.0-be.785%2B6abdba4.zip'

function Write-BigWalkHeader {
    param([Parameter(Mandatory = $true)][string]$Title)

    Write-Host ''
    Write-Host '==================================================' -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host '==================================================' -ForegroundColor Cyan
    Write-Host ''
}

function Get-SteamRoots {
    $roots = @()
    $registryPaths = @(
        'HKCU:\Software\Valve\Steam',
        'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam',
        'HKLM:\SOFTWARE\Valve\Steam'
    )

    foreach ($registryPath in $registryPaths) {
        if (Test-Path -LiteralPath $registryPath) {
            $steamInfo = Get-ItemProperty -LiteralPath $registryPath -ErrorAction SilentlyContinue
            $steamPathProperty = $steamInfo.PSObject.Properties['SteamPath']
            $installPathProperty = $steamInfo.PSObject.Properties['InstallPath']
            if ($steamPathProperty -and $steamPathProperty.Value) { $roots += $steamPathProperty.Value }
            if ($installPathProperty -and $installPathProperty.Value) { $roots += $installPathProperty.Value }
        }
    }

    $roots += (Join-Path $env:ProgramFiles 'Steam')
    if (${env:ProgramFiles(x86)}) {
        $roots += (Join-Path ${env:ProgramFiles(x86)} 'Steam')
    }

    return @($roots | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique)
}

function Get-SteamLibraries {
    param([Parameter(Mandatory = $true)][array]$SteamRoots)

    $libraries = @()
    foreach ($steamRoot in $SteamRoots) {
        $libraries += $steamRoot
        $libraryFile = Join-Path $steamRoot 'steamapps\libraryfolders.vdf'

        if (Test-Path -LiteralPath $libraryFile) {
            try {
                $content = Get-Content -LiteralPath $libraryFile -Raw -ErrorAction Stop
                $pathMatches = [regex]::Matches($content, '"path"\s+"([^"]+)"')
                foreach ($pathMatch in $pathMatches) {
                    $libraryPath = $pathMatch.Groups[1].Value -replace '\\\\', '\'
                    if (Test-Path -LiteralPath $libraryPath) {
                        $libraries += $libraryPath
                    }
                }
            }
            catch {
                Write-Host "Warning: Could not read $libraryFile" -ForegroundColor Yellow
            }
        }
    }

    return @($libraries | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique)
}

function Find-BigWalkFolder {
    $steamRoots = @(Get-SteamRoots)
    $libraries = @()
    if ($steamRoots.Count -gt 0) {
        $libraries = @(Get-SteamLibraries -SteamRoots $steamRoots)
    }

    foreach ($library in $libraries) {
        $manifest = Join-Path $library "steamapps\appmanifest_$($script:BigWalkAppId).acf"
        if (Test-Path -LiteralPath $manifest) {
            try {
                $manifestText = Get-Content -LiteralPath $manifest -Raw -ErrorAction Stop
                if ($manifestText -match '"installdir"\s+"([^"]+)"') {
                    $candidate = Join-Path $library "steamapps\common\$($Matches[1])"
                    if (Test-Path -LiteralPath (Join-Path $candidate 'Big Walk.exe')) {
                        return $candidate
                    }
                }
            }
            catch {}
        }

        $candidate = Join-Path $library 'steamapps\common\Big Walk'
        if (Test-Path -LiteralPath (Join-Path $candidate 'Big Walk.exe')) {
            return $candidate
        }
    }

    foreach ($drive in (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
        $candidates = @(
            (Join-Path $drive.Root 'SteamLibrary\steamapps\common\Big Walk'),
            (Join-Path $drive.Root 'Steam\steamapps\common\Big Walk'),
            (Join-Path $drive.Root 'Games\SteamLibrary\steamapps\common\Big Walk'),
            (Join-Path $drive.Root 'Games\Steam\steamapps\common\Big Walk')
        )

        foreach ($candidate in $candidates) {
            if (Test-Path -LiteralPath (Join-Path $candidate 'Big Walk.exe')) {
                return $candidate
            }
        }
    }

    Write-Host 'Big Walk could not be found automatically.' -ForegroundColor Yellow
    $manualFolder = Read-Host 'Paste the Big Walk game folder, or press Enter to cancel'
    $manualFolder = $manualFolder.Trim().Trim('"')

    if ($manualFolder -and (Test-Path -LiteralPath (Join-Path $manualFolder 'Big Walk.exe'))) {
        return $manualFolder
    }

    throw 'Big Walk was not found. In Steam, open Big Walk > Properties > Installed Files > Browse.'
}

function Stop-BigWalkIfRunning {
    $runningGame = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -like '*Big Walk*'
    })

    if ($runningGame.Count -eq 0) { return }

    Write-Host 'Big Walk is currently running.' -ForegroundColor Yellow
    $answer = Read-Host 'Close Big Walk now? (Y/N)'
    if ($answer -notmatch '^[Yy]') {
        throw 'Close Big Walk before changing its mods.'
    }

    $runningGame | Stop-Process -Force -ErrorAction Stop
    Start-Sleep -Seconds 2
}

function Invoke-BigWalkDownload {
    param(
        [Parameter(Mandatory = $true)][string]$Uri,
        [Parameter(Mandatory = $true)][string]$OutFile,
        [Parameter(Mandatory = $true)][string]$Description
    )

    Write-Host "Downloading $Description..." -ForegroundColor Cyan
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $OutFile -ErrorAction Stop

    if (-not (Test-Path -LiteralPath $OutFile)) {
        throw "$Description did not download."
    }

    if ((Get-Item -LiteralPath $OutFile).Length -lt 1000) {
        throw "The $Description download was unexpectedly small and may be invalid."
    }

    Write-Host "[OK] Downloaded $Description" -ForegroundColor Green
}

function New-BigWalkTempFolder {
    param([Parameter(Mandatory = $true)][string]$Name)

    $folder = Join-Path $env:TEMP ("BigWalkModManager\{0}-{1}" -f $Name, [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    return $folder
}

function Test-BepInExInstalled {
    param([Parameter(Mandatory = $true)][string]$GameFolder)

    return (
        (Test-Path -LiteralPath (Join-Path $GameFolder 'BepInEx')) -and
        (Test-Path -LiteralPath (Join-Path $GameFolder 'winhttp.dll')) -and
        (Test-Path -LiteralPath (Join-Path $GameFolder 'doorstop_config.ini'))
    )
}

function Install-BepInExIfNeeded {
    param([Parameter(Mandatory = $true)][string]$GameFolder)

    if (Test-BepInExInstalled -GameFolder $GameFolder) {
        Write-Host '[OK] BepInEx is already installed' -ForegroundColor Green
        return
    }

    Write-Host 'BepInEx is missing or incomplete. Installing it now...' -ForegroundColor Yellow
    $tempFolder = New-BigWalkTempFolder -Name 'BepInEx'

    try {
        $zipFile = Join-Path $tempFolder 'BepInEx.zip'
        $extractFolder = Join-Path $tempFolder 'Extracted'
        New-Item -ItemType Directory -Path $extractFolder -Force | Out-Null

        Invoke-BigWalkDownload -Uri $script:BepInExUrl -OutFile $zipFile -Description "BepInEx $($script:BepInExVersion) IL2CPP x64"
        Expand-Archive -LiteralPath $zipFile -DestinationPath $extractFolder -Force

        $bepRoot = Get-ChildItem -LiteralPath $extractFolder -Directory -Recurse -ErrorAction SilentlyContinue |
            Where-Object {
                (Test-Path -LiteralPath (Join-Path $_.FullName 'BepInEx')) -and
                (Test-Path -LiteralPath (Join-Path $_.FullName 'winhttp.dll'))
            } |
            Select-Object -First 1

        if ($bepRoot) {
            $sourceRoot = $bepRoot.FullName
        }
        elseif (
            (Test-Path -LiteralPath (Join-Path $extractFolder 'BepInEx')) -and
            (Test-Path -LiteralPath (Join-Path $extractFolder 'winhttp.dll'))
        ) {
            $sourceRoot = $extractFolder
        }
        else {
            throw 'The downloaded BepInEx archive did not contain the expected loader files.'
        }

        Copy-Item -Path (Join-Path $sourceRoot '*') -Destination $GameFolder -Recurse -Force

        if (-not (Test-BepInExInstalled -GameFolder $GameFolder)) {
            throw 'BepInEx installation could not be verified.'
        }

        Write-Host '[OK] BepInEx installed' -ForegroundColor Green
    }
    finally {
        Remove-Item -LiteralPath $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Get-LatestThunderstorePackage {
    param(
        [Parameter(Mandatory = $true)][string]$Namespace,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$FallbackVersion
    )

    $apiUri = "https://thunderstore.io/api/experimental/package/$Namespace/$Name/"
    try {
        $package = Invoke-RestMethod -UseBasicParsing -Uri $apiUri -ErrorAction Stop
        $latestProperty = $package.PSObject.Properties['latest']
        $latest = if ($latestProperty) { $latestProperty.Value } else { $null }
        $versionProperty = if ($latest) { $latest.PSObject.Properties['version_number'] } else { $null }
        $downloadProperty = if ($latest) { $latest.PSObject.Properties['download_url'] } else { $null }
        if ($versionProperty -and $versionProperty.Value -and $downloadProperty -and $downloadProperty.Value) {
            return [pscustomobject]@{
                Version = [string]$versionProperty.Value
                DownloadUrl = [string]$downloadProperty.Value
            }
        }
    }
    catch {
        Write-Host 'Could not check Thunderstore for the newest version; using the tested fallback.' -ForegroundColor Yellow
    }

    return [pscustomobject]@{
        Version = $FallbackVersion
        DownloadUrl = "https://thunderstore.io/package/download/$Namespace/$Name/$FallbackVersion/"
    }
}

function Install-ThunderstoreMod {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Namespace,
        [Parameter(Mandatory = $true)][string]$DllName,
        [Parameter(Mandatory = $true)][string]$FallbackVersion
    )

    Write-BigWalkHeader -Title "Install or update $Name"
    $gameFolder = Find-BigWalkFolder
    Write-Host "[OK] Big Walk found: $gameFolder" -ForegroundColor Green

    Stop-BigWalkIfRunning
    Install-BepInExIfNeeded -GameFolder $gameFolder

    $package = Get-LatestThunderstorePackage -Namespace $Namespace -Name $Name -FallbackVersion $FallbackVersion
    $tempFolder = New-BigWalkTempFolder -Name $Name

    try {
        $zipFile = Join-Path $tempFolder "$Name.zip"
        $extractFolder = Join-Path $tempFolder 'Extracted'
        New-Item -ItemType Directory -Path $extractFolder -Force | Out-Null

        Invoke-BigWalkDownload -Uri $package.DownloadUrl -OutFile $zipFile -Description "$Name $($package.Version)"
        Expand-Archive -LiteralPath $zipFile -DestinationPath $extractFolder -Force

        $dllFile = Get-ChildItem -LiteralPath $extractFolder -Filter $DllName -File -Recurse -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if (-not $dllFile) {
            throw "$DllName was not found in the downloaded $Name package."
        }

        $pluginsFolder = Join-Path $gameFolder 'BepInEx\plugins'
        $destinationFolder = Join-Path $pluginsFolder $Name
        New-Item -ItemType Directory -Path $pluginsFolder -Force | Out-Null

        Get-ChildItem -LiteralPath $pluginsFolder -Filter $DllName -File -Recurse -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $destinationFolder -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Path $destinationFolder -Force | Out-Null

        Copy-Item -Path (Join-Path $dllFile.Directory.FullName '*') -Destination $destinationFolder -Recurse -Force

        $installedDll = Get-ChildItem -LiteralPath $destinationFolder -Filter $DllName -File -Recurse -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if (-not $installedDll) {
            throw "$Name installation could not be verified."
        }

        Write-Host ''
        Write-Host "[OK] $Name $($package.Version) installed" -ForegroundColor Green
        Write-Host "     $($installedDll.FullName)"
        Write-Host ''
        Write-Host 'The first launch after installing BepInEx may take longer than normal.' -ForegroundColor Yellow
    }
    finally {
        Remove-Item -LiteralPath $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Uninstall-BigWalkMod {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$DllName
    )

    Write-BigWalkHeader -Title "Uninstall $Name"
    $gameFolder = Find-BigWalkFolder
    Write-Host "[OK] Big Walk found: $gameFolder" -ForegroundColor Green
    Stop-BigWalkIfRunning

    $pluginsFolder = Join-Path $gameFolder 'BepInEx\plugins'
    $destinationFolder = Join-Path $pluginsFolder $Name
    $removed = $false

    if (Test-Path -LiteralPath $destinationFolder) {
        Remove-Item -LiteralPath $destinationFolder -Recurse -Force
        $removed = $true
    }

    if (Test-Path -LiteralPath $pluginsFolder) {
        $legacyDlls = @(Get-ChildItem -LiteralPath $pluginsFolder -Filter $DllName -File -Recurse -ErrorAction SilentlyContinue)
        foreach ($legacyDll in $legacyDlls) {
            Remove-Item -LiteralPath $legacyDll.FullName -Force
            $removed = $true
        }
    }

    $configFolder = Join-Path $gameFolder 'BepInEx\config'
    if (Test-Path -LiteralPath $configFolder) {
        Get-ChildItem -LiteralPath $configFolder -Filter "*$Name*" -File -Recurse -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }

    if ($removed) {
        Write-Host "[OK] $Name was removed" -ForegroundColor Green
    }
    else {
        Write-Host "[SKIP] $Name was not installed" -ForegroundColor DarkGray
    }

    Write-Host 'BepInEx and other mods were left in place.'
}

function Uninstall-AllBigWalkModsAndBepInEx {
    Write-BigWalkHeader -Title 'Remove all mods and BepInEx'
    $gameFolder = Find-BigWalkFolder
    Write-Host "[OK] Big Walk found: $gameFolder" -ForegroundColor Green
    Write-Host ''
    Write-Host 'WARNING: This removes every BepInEx mod, config, cache, and log.' -ForegroundColor Yellow
    Write-Host 'The Big Walk game itself and saved games will not be deleted.' -ForegroundColor Green
    Write-Host ''

    $confirmation = Read-Host 'Type YES to remove all mods and BepInEx'
    if ($confirmation -cne 'YES') {
        Write-Host 'Cancelled. Nothing was removed.' -ForegroundColor Yellow
        return
    }

    Stop-BigWalkIfRunning

    $hadBepInExMarkers = (
        (Test-Path -LiteralPath (Join-Path $gameFolder 'BepInEx')) -or
        (Test-Path -LiteralPath (Join-Path $gameFolder 'winhttp.dll')) -or
        (Test-Path -LiteralPath (Join-Path $gameFolder 'doorstop_config.ini'))
    )

    $targets = @(
        @{ Path = (Join-Path $gameFolder 'BepInEx'); Description = 'BepInEx folder and all mods' },
        @{ Path = (Join-Path $gameFolder 'winhttp.dll'); Description = 'winhttp.dll loader' },
        @{ Path = (Join-Path $gameFolder 'doorstop_config.ini'); Description = 'doorstop_config.ini' },
        @{ Path = (Join-Path $gameFolder '.doorstop_version'); Description = '.doorstop_version' }
    )

    $dotNetFolder = Join-Path $gameFolder 'dotnet'
    if ($hadBepInExMarkers -and (Test-Path -LiteralPath (Join-Path $dotNetFolder 'coreclr.dll'))) {
        $targets += @{ Path = $dotNetFolder; Description = 'BepInEx bundled .NET runtime' }
    }

    foreach ($target in $targets) {
        if (Test-Path -LiteralPath $target.Path) {
            Write-Host "Removing $($target.Description)..." -ForegroundColor Yellow
            Remove-Item -LiteralPath $target.Path -Recurse -Force -ErrorAction Stop
            Write-Host "[OK] Removed $($target.Description)" -ForegroundColor Green
        }
        else {
            Write-Host "[SKIP] $($target.Description) not found" -ForegroundColor DarkGray
        }
    }

    $remaining = @($targets | Where-Object { Test-Path -LiteralPath $_.Path })
    if ($remaining.Count -gt 0) {
        throw 'Some BepInEx files remain. Restart Windows and run the uninstaller again.'
    }

    Write-Host ''
    Write-Host '[OK] All BepInEx mods and BepInEx were removed' -ForegroundColor Green
}

function Show-BigWalkModStatus {
    Write-BigWalkHeader -Title 'Mod status'
    $gameFolder = Find-BigWalkFolder
    Write-Host "Big Walk: $gameFolder"
    Write-Host ''

    if (Test-BepInExInstalled -GameFolder $gameFolder) {
        Write-Host '[INSTALLED] BepInEx' -ForegroundColor Green
    }
    else {
        Write-Host '[NOT INSTALLED] BepInEx' -ForegroundColor DarkGray
    }

    $pluginsFolder = Join-Path $gameFolder 'BepInEx\plugins'
    foreach ($mod in @(
        @{ Name = 'BigDart'; Dll = 'BigDart.dll' },
        @{ Name = 'BigYeet'; Dll = 'BigYeet.dll' }
    )) {
        $found = $null
        if (Test-Path -LiteralPath $pluginsFolder) {
            $found = Get-ChildItem -LiteralPath $pluginsFolder -Filter $mod.Dll -File -Recurse -ErrorAction SilentlyContinue |
                Select-Object -First 1
        }

        if ($found) {
            Write-Host "[INSTALLED] $($mod.Name)" -ForegroundColor Green
            Write-Host "            $($found.FullName)" -ForegroundColor DarkGray
        }
        else {
            Write-Host "[NOT INSTALLED] $($mod.Name)" -ForegroundColor DarkGray
        }
    }
}
