@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Big Walk Mod Manager

rem Public GitHub repository used for automatic PowerShell downloads.
set "BIGWALK_RAW_BASE=https://raw.githubusercontent.com/DooleyDigital/bwmod/main"
set "BIGWALK_TEMP_DIR=%TEMP%\BigWalkModManager"
set "BIGWALK_LAUNCHER=%~f0"

rem Request administrator rights so Steam installs under Program Files are writable.
fltmc >nul 2>&1
if errorlevel 1 (
    echo Requesting administrator permission...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:BIGWALK_LAUNCHER -Verb RunAs"
    exit /b
)

:MENU
cls
echo ==================================================
echo              BIG WALK MOD MANAGER
echo ==================================================
echo.
echo   1. Select mods to install or update
echo   2. Select mods to uninstall
echo   3. Remove ALL mods and BepInEx
echo.
echo   4. Check mod status
echo   5. Launch Big Walk
echo   0. Exit
echo.
choice /C 123450 /N /M "Choose an option: "
set "CHOICE=!errorlevel!"

if "!CHOICE!"=="1" call :INSTALL_MENU
if "!CHOICE!"=="2" call :UNINSTALL_MENU
if "!CHOICE!"=="3" call :RUN_SCRIPT Uninstall-AllModsAndBepInEx.ps1
if "!CHOICE!"=="4" call :RUN_SCRIPT Get-ModStatus.ps1
if "!CHOICE!"=="5" start "" "steam://run/1478500"
if "!CHOICE!"=="6" exit /b 0

if not "!CHOICE!"=="5" (
    echo.
    pause
)
goto MENU

:RESET_SELECTIONS
set "SEL_YEET=0"
set "SEL_DART=0"
set "SEL_TELEPORT=0"
set "SEL_FIREWORK=0"
set "SEL_MINIMAP=0"
set "SEL_NOCLIP=0"
set "SEL_TRAINS=0"
set "SEL_QUICKBELT=0"
set "SEL_ITEMDEBUG=0"
set "SEL_BIGRUN=0"
set "SEL_PARACHUTE=0"
set "SEL_TELEPORTPLAYER=0"
set "SEL_BIGBACK=0"
set "SEL_HIDENSEEK=0"
exit /b 0

:INSTALL_MENU
call :RESET_SELECTIONS

:INSTALL_MENU_LOOP
call :SET_MARKS
cls
echo ==================================================
echo             SELECT MODS TO INSTALL
echo ==================================================
echo.
echo Press a mod's key to toggle it on or off.
echo [X] = WILL INSTALL       [ ] = WILL NOT INSTALL
echo Nothing is selected by default. Press I when ready.
echo.
echo   1. [!MARK_YEET!] BigYeet           - Charged player throws
echo   2. [!MARK_DART!] BigDart           - Darts and smoke effects
echo   3. [!MARK_TELEPORT!] BigTeleport       - Map and puzzle teleporting
echo   4. [!MARK_FIREWORK!] BigFirework       - Host firework shows
echo   5. [!MARK_MINIMAP!] Mady's MiniMap    - Map, minimap and waypoints
echo   6. [!MARK_NOCLIP!] NoClip            - Host-only free flight
echo   7. [!MARK_TRAINS!] Better Trains     - Faster host-controlled trains
echo   8. [!MARK_QUICKBELT!] QuickBelt         - One-key belt access
echo   9. [!MARK_ITEMDEBUG!] Item Debug        - Item and colour debug panel
echo   A. [!MARK_BIGRUN!] Big Run           - Toggle super speed and jump
echo   B. [!MARK_PARACHUTE!] MapParachute      - Use the map as a parachute
echo   C. [!MARK_TELEPORTPLAYER!] TeleportToPlayer  - Teleport to another player
echo   D. [!MARK_BIGBACK!] BigBack           - Carry large items in slots
echo   E. [!MARK_HIDENSEEK!] Mady's HideNSeek  - Host hide-and-seek mode
echo.
echo   I. INSTALL or update every mod marked [X]
echo   0. Back
echo.
choice /C 123456789ABCDEI0 /N /M "Choose a mod key, I to install, or 0 to go back: "
set "SELECT_CHOICE=!errorlevel!"

if "!SELECT_CHOICE!"=="1" call :TOGGLE SEL_YEET
if "!SELECT_CHOICE!"=="2" call :TOGGLE SEL_DART
if "!SELECT_CHOICE!"=="3" call :TOGGLE SEL_TELEPORT
if "!SELECT_CHOICE!"=="4" call :TOGGLE SEL_FIREWORK
if "!SELECT_CHOICE!"=="5" call :TOGGLE SEL_MINIMAP
if "!SELECT_CHOICE!"=="6" call :TOGGLE SEL_NOCLIP
if "!SELECT_CHOICE!"=="7" call :TOGGLE SEL_TRAINS
if "!SELECT_CHOICE!"=="8" call :TOGGLE SEL_QUICKBELT
if "!SELECT_CHOICE!"=="9" call :TOGGLE SEL_ITEMDEBUG
if "!SELECT_CHOICE!"=="10" call :TOGGLE SEL_BIGRUN
if "!SELECT_CHOICE!"=="11" call :TOGGLE SEL_PARACHUTE
if "!SELECT_CHOICE!"=="12" call :TOGGLE SEL_TELEPORTPLAYER
if "!SELECT_CHOICE!"=="13" call :TOGGLE SEL_BIGBACK
if "!SELECT_CHOICE!"=="14" call :TOGGLE SEL_HIDENSEEK
if "!SELECT_CHOICE!"=="15" (
    call :BUILD_SELECTION
    if not defined SELECTED_MODS (
        echo.
        echo Nothing is marked [X]. Select at least one mod first.
        pause
        goto INSTALL_MENU_LOOP
    )
    call :RUN_SELECTION Install "!SELECTED_MODS!"
    exit /b !errorlevel!
)
if "!SELECT_CHOICE!"=="16" exit /b 0
goto INSTALL_MENU_LOOP

:UNINSTALL_MENU
call :RESET_SELECTIONS

:UNINSTALL_MENU_LOOP
call :SET_MARKS
cls
echo ==================================================
echo            SELECT MODS TO UNINSTALL
echo ==================================================
echo.
echo Press a mod's key to toggle it on or off.
echo [X] = WILL REMOVE        [ ] = WILL KEEP
echo Nothing is selected by default. Press U when ready.
echo BepInEx and unselected mods will remain installed.
echo.
echo   1. [!MARK_YEET!] BigYeet
echo   2. [!MARK_DART!] BigDart
echo   3. [!MARK_TELEPORT!] BigTeleport
echo   4. [!MARK_FIREWORK!] BigFirework
echo   5. [!MARK_MINIMAP!] Mady's MiniMap
echo   6. [!MARK_NOCLIP!] NoClip
echo   7. [!MARK_TRAINS!] Better Trains
echo   8. [!MARK_QUICKBELT!] QuickBelt
echo   9. [!MARK_ITEMDEBUG!] Item Debug
echo   A. [!MARK_BIGRUN!] Big Run
echo   B. [!MARK_PARACHUTE!] MapParachute
echo   C. [!MARK_TELEPORTPLAYER!] TeleportToPlayer
echo   D. [!MARK_BIGBACK!] BigBack
echo   E. [!MARK_HIDENSEEK!] Mady's HideNSeek
echo.
echo   U. UNINSTALL every mod marked [X]
echo   0. Back
echo.
choice /C 123456789ABCDEU0 /N /M "Choose a mod key, U to uninstall, or 0 to go back: "
set "SELECT_CHOICE=!errorlevel!"

if "!SELECT_CHOICE!"=="1" call :TOGGLE SEL_YEET
if "!SELECT_CHOICE!"=="2" call :TOGGLE SEL_DART
if "!SELECT_CHOICE!"=="3" call :TOGGLE SEL_TELEPORT
if "!SELECT_CHOICE!"=="4" call :TOGGLE SEL_FIREWORK
if "!SELECT_CHOICE!"=="5" call :TOGGLE SEL_MINIMAP
if "!SELECT_CHOICE!"=="6" call :TOGGLE SEL_NOCLIP
if "!SELECT_CHOICE!"=="7" call :TOGGLE SEL_TRAINS
if "!SELECT_CHOICE!"=="8" call :TOGGLE SEL_QUICKBELT
if "!SELECT_CHOICE!"=="9" call :TOGGLE SEL_ITEMDEBUG
if "!SELECT_CHOICE!"=="10" call :TOGGLE SEL_BIGRUN
if "!SELECT_CHOICE!"=="11" call :TOGGLE SEL_PARACHUTE
if "!SELECT_CHOICE!"=="12" call :TOGGLE SEL_TELEPORTPLAYER
if "!SELECT_CHOICE!"=="13" call :TOGGLE SEL_BIGBACK
if "!SELECT_CHOICE!"=="14" call :TOGGLE SEL_HIDENSEEK
if "!SELECT_CHOICE!"=="15" (
    call :BUILD_SELECTION
    if not defined SELECTED_MODS (
        echo.
        echo Nothing is marked [X]. Select at least one mod first.
        pause
        goto UNINSTALL_MENU_LOOP
    )
    call :RUN_SELECTION Uninstall "!SELECTED_MODS!"
    exit /b !errorlevel!
)
if "!SELECT_CHOICE!"=="16" exit /b 0
goto UNINSTALL_MENU_LOOP

:TOGGLE
if "!%~1!"=="1" (
    set "%~1=0"
) else (
    set "%~1=1"
)
exit /b 0

:SET_MARKS
if "!SEL_YEET!"=="1" (set "MARK_YEET=X") else (set "MARK_YEET= ")
if "!SEL_DART!"=="1" (set "MARK_DART=X") else (set "MARK_DART= ")
if "!SEL_TELEPORT!"=="1" (set "MARK_TELEPORT=X") else (set "MARK_TELEPORT= ")
if "!SEL_FIREWORK!"=="1" (set "MARK_FIREWORK=X") else (set "MARK_FIREWORK= ")
if "!SEL_MINIMAP!"=="1" (set "MARK_MINIMAP=X") else (set "MARK_MINIMAP= ")
if "!SEL_NOCLIP!"=="1" (set "MARK_NOCLIP=X") else (set "MARK_NOCLIP= ")
if "!SEL_TRAINS!"=="1" (set "MARK_TRAINS=X") else (set "MARK_TRAINS= ")
if "!SEL_QUICKBELT!"=="1" (set "MARK_QUICKBELT=X") else (set "MARK_QUICKBELT= ")
if "!SEL_ITEMDEBUG!"=="1" (set "MARK_ITEMDEBUG=X") else (set "MARK_ITEMDEBUG= ")
if "!SEL_BIGRUN!"=="1" (set "MARK_BIGRUN=X") else (set "MARK_BIGRUN= ")
if "!SEL_PARACHUTE!"=="1" (set "MARK_PARACHUTE=X") else (set "MARK_PARACHUTE= ")
if "!SEL_TELEPORTPLAYER!"=="1" (set "MARK_TELEPORTPLAYER=X") else (set "MARK_TELEPORTPLAYER= ")
if "!SEL_BIGBACK!"=="1" (set "MARK_BIGBACK=X") else (set "MARK_BIGBACK= ")
if "!SEL_HIDENSEEK!"=="1" (set "MARK_HIDENSEEK=X") else (set "MARK_HIDENSEEK= ")
exit /b 0

:BUILD_SELECTION
set "SELECTED_MODS="
if "!SEL_YEET!"=="1" call :ADD_SELECTED BigYeet
if "!SEL_DART!"=="1" call :ADD_SELECTED BigDart
if "!SEL_TELEPORT!"=="1" call :ADD_SELECTED BigTeleport
if "!SEL_FIREWORK!"=="1" call :ADD_SELECTED BigFirework
if "!SEL_MINIMAP!"=="1" call :ADD_SELECTED Madys_MiniMap
if "!SEL_NOCLIP!"=="1" call :ADD_SELECTED NoClip
if "!SEL_TRAINS!"=="1" call :ADD_SELECTED Better_Trains
if "!SEL_QUICKBELT!"=="1" call :ADD_SELECTED QuickBelt
if "!SEL_ITEMDEBUG!"=="1" call :ADD_SELECTED Item_Debug
if "!SEL_BIGRUN!"=="1" call :ADD_SELECTED Big_Run
if "!SEL_PARACHUTE!"=="1" call :ADD_SELECTED MapParachute
if "!SEL_TELEPORTPLAYER!"=="1" call :ADD_SELECTED TeleportToPlayer
if "!SEL_BIGBACK!"=="1" call :ADD_SELECTED BigBack
if "!SEL_HIDENSEEK!"=="1" call :ADD_SELECTED Madys_HideNSeek
exit /b 0

:ADD_SELECTED
if defined SELECTED_MODS (
    set "SELECTED_MODS=!SELECTED_MODS!,%~1"
) else (
    set "SELECTED_MODS=%~1"
)
exit /b 0

:RUN_SELECTION
set "SELECTION_ACTION=%~1"
set "SELECTION_MODS=%~2"
if not exist "%BIGWALK_TEMP_DIR%" mkdir "%BIGWALK_TEMP_DIR%" >nul 2>&1

echo.
echo Downloading the latest mod manager scripts from GitHub...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri ($env:BIGWALK_RAW_BASE + '/scripts/Common.ps1') -OutFile (Join-Path $env:BIGWALK_TEMP_DIR 'Common.ps1'); Invoke-WebRequest -UseBasicParsing -Uri ($env:BIGWALK_RAW_BASE + '/scripts/Manage-SelectedMods.ps1') -OutFile (Join-Path $env:BIGWALK_TEMP_DIR 'Manage-SelectedMods.ps1')"

if errorlevel 1 (
    echo.
    echo ERROR: The scripts could not be downloaded from GitHub.
    echo Check your internet connection and try again.
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\Manage-SelectedMods.ps1" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1" -Action "%SELECTION_ACTION%" -Mods "%SELECTION_MODS%"
exit /b !errorlevel!

:RUN_SCRIPT
set "ACTION_SCRIPT=%~1"
if not exist "%BIGWALK_TEMP_DIR%" mkdir "%BIGWALK_TEMP_DIR%" >nul 2>&1

echo.
echo Downloading the latest mod manager scripts from GitHub...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri ($env:BIGWALK_RAW_BASE + '/scripts/Common.ps1') -OutFile (Join-Path $env:BIGWALK_TEMP_DIR 'Common.ps1'); Invoke-WebRequest -UseBasicParsing -Uri ($env:BIGWALK_RAW_BASE + '/scripts/%ACTION_SCRIPT%') -OutFile (Join-Path $env:BIGWALK_TEMP_DIR '%ACTION_SCRIPT%')"

if errorlevel 1 (
    echo.
    echo ERROR: The scripts could not be downloaded from GitHub.
    echo Check your internet connection and try again.
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\%ACTION_SCRIPT%" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1"
exit /b !errorlevel!
