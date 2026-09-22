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

:INSTALL_MENU
set "SEL_YEET=1"
set "SEL_DART=1"
set "SEL_TELEPORT=0"
set "SEL_FIREWORK=0"
set "SEL_MINIMAP=0"

:INSTALL_MENU_LOOP
call :SET_MARKS
cls
echo ==================================================
echo             SELECT MODS TO INSTALL
echo ==================================================
echo.
echo Press 1-5 to toggle each mod on or off.
echo [X] = WILL INSTALL       [ ] = WILL NOT INSTALL
echo When the list looks right, press I to continue.
echo BigYeet and BigDart start selected but can be turned off.
echo.
echo   1. [!MARK_YEET!] BigYeet         - Charged player throws
echo   2. [!MARK_DART!] BigDart         - Darts and smoke effects
echo   3. [!MARK_TELEPORT!] BigTeleport     - Map and puzzle teleporting
echo   4. [!MARK_FIREWORK!] BigFirework     - Host firework shows
echo   5. [!MARK_MINIMAP!] Mady's MiniMap  - Map, minimap and waypoints
echo.
echo   I. Install or update checked mods
echo   0. Back
echo.
choice /C 12345I0 /N /M "Choose an option: "
set "SELECT_CHOICE=!errorlevel!"

if "!SELECT_CHOICE!"=="1" call :TOGGLE SEL_YEET
if "!SELECT_CHOICE!"=="2" call :TOGGLE SEL_DART
if "!SELECT_CHOICE!"=="3" call :TOGGLE SEL_TELEPORT
if "!SELECT_CHOICE!"=="4" call :TOGGLE SEL_FIREWORK
if "!SELECT_CHOICE!"=="5" call :TOGGLE SEL_MINIMAP
if "!SELECT_CHOICE!"=="6" (
    call :BUILD_SELECTION
    if not defined SELECTED_MODS (
        echo.
        echo Select at least one mod first.
        pause
        goto INSTALL_MENU_LOOP
    )
    call :RUN_SELECTION Install "!SELECTED_MODS!"
    exit /b !errorlevel!
)
if "!SELECT_CHOICE!"=="7" exit /b 0
goto INSTALL_MENU_LOOP

:UNINSTALL_MENU
set "SEL_YEET=0"
set "SEL_DART=0"
set "SEL_TELEPORT=0"
set "SEL_FIREWORK=0"
set "SEL_MINIMAP=0"

:UNINSTALL_MENU_LOOP
call :SET_MARKS
cls
echo ==================================================
echo            SELECT MODS TO UNINSTALL
echo ==================================================
echo.
echo Press 1-5 to toggle each mod on or off.
echo [X] = WILL REMOVE        [ ] = WILL KEEP
echo When the list looks right, press U to continue.
echo BepInEx and unselected mods will remain installed.
echo.
echo   1. [!MARK_YEET!] BigYeet
echo   2. [!MARK_DART!] BigDart
echo   3. [!MARK_TELEPORT!] BigTeleport
echo   4. [!MARK_FIREWORK!] BigFirework
echo   5. [!MARK_MINIMAP!] Mady's MiniMap
echo.
echo   U. Uninstall checked mods
echo   0. Back
echo.
choice /C 12345U0 /N /M "Choose an option: "
set "SELECT_CHOICE=!errorlevel!"

if "!SELECT_CHOICE!"=="1" call :TOGGLE SEL_YEET
if "!SELECT_CHOICE!"=="2" call :TOGGLE SEL_DART
if "!SELECT_CHOICE!"=="3" call :TOGGLE SEL_TELEPORT
if "!SELECT_CHOICE!"=="4" call :TOGGLE SEL_FIREWORK
if "!SELECT_CHOICE!"=="5" call :TOGGLE SEL_MINIMAP
if "!SELECT_CHOICE!"=="6" (
    call :BUILD_SELECTION
    if not defined SELECTED_MODS (
        echo.
        echo Select at least one mod first.
        pause
        goto UNINSTALL_MENU_LOOP
    )
    call :RUN_SELECTION Uninstall "!SELECTED_MODS!"
    exit /b !errorlevel!
)
if "!SELECT_CHOICE!"=="7" exit /b 0
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
exit /b 0

:BUILD_SELECTION
set "SELECTED_MODS="
if "!SEL_YEET!"=="1" call :ADD_SELECTED BigYeet
if "!SEL_DART!"=="1" call :ADD_SELECTED BigDart
if "!SEL_TELEPORT!"=="1" call :ADD_SELECTED BigTeleport
if "!SEL_FIREWORK!"=="1" call :ADD_SELECTED BigFirework
if "!SEL_MINIMAP!"=="1" call :ADD_SELECTED Madys_MiniMap
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
