@echo off
setlocal EnableExtensions
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
echo   1. Install or update BigDart
echo   2. Install or update BigYeet
echo   3. Install or update BOTH mods
echo.
echo   4. Uninstall BigDart
echo   5. Uninstall BigYeet
echo   6. Remove ALL mods and BepInEx
echo.
echo   7. Check mod status
echo   8. Launch Big Walk
echo   0. Exit
echo.
choice /C 123456780 /N /M "Choose an option: "
set "CHOICE=%errorlevel%"

if "%CHOICE%"=="1" call :RUN_SCRIPT Install-BigDart.ps1
if "%CHOICE%"=="2" call :RUN_SCRIPT Install-BigYeet.ps1
if "%CHOICE%"=="3" call :INSTALL_BOTH
if "%CHOICE%"=="4" call :RUN_SCRIPT Uninstall-BigDart.ps1
if "%CHOICE%"=="5" call :RUN_SCRIPT Uninstall-BigYeet.ps1
if "%CHOICE%"=="6" call :RUN_SCRIPT Uninstall-AllModsAndBepInEx.ps1
if "%CHOICE%"=="7" call :RUN_SCRIPT Get-ModStatus.ps1
if "%CHOICE%"=="8" start "" "steam://run/1478500"
if "%CHOICE%"=="9" exit /b 0

if not "%CHOICE%"=="8" (
    echo.
    pause
)
goto MENU

:INSTALL_BOTH
call :DOWNLOAD_FILES Install-BigDart.ps1
if errorlevel 1 exit /b 1
call :DOWNLOAD_FILES Install-BigYeet.ps1
if errorlevel 1 exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\Install-BigDart.ps1" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1"
if errorlevel 1 exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\Install-BigYeet.ps1" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1"
exit /b %errorlevel%

:RUN_SCRIPT
set "ACTION_SCRIPT=%~1"
call :DOWNLOAD_FILES "%ACTION_SCRIPT%"
if errorlevel 1 exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\%ACTION_SCRIPT%" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1"
exit /b %errorlevel%

:DOWNLOAD_FILES
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

exit /b 0
