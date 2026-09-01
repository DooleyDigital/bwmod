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
echo   1. Install or update BigYeet + Mystery Mod
echo.
echo   2. Uninstall BigYeet + Mystery Mod
echo   3. Remove ALL mods and BepInEx
echo.
echo   4. Check mod status
echo   5. Launch Big Walk
echo   0. Exit
echo.
choice /C 123450 /N /M "Choose an option: "
set "CHOICE=%errorlevel%"

if "%CHOICE%"=="1" call :INSTALL_SURPRISE_PACK
if "%CHOICE%"=="2" call :UNINSTALL_SURPRISE_PACK
if "%CHOICE%"=="3" call :RUN_SCRIPT Uninstall-AllModsAndBepInEx.ps1
if "%CHOICE%"=="4" call :RUN_SCRIPT Get-ModStatus.ps1
if "%CHOICE%"=="5" start "" "steam://run/1478500"
if "%CHOICE%"=="6" exit /b 0

if not "%CHOICE%"=="5" (
    echo.
    pause
)
goto MENU

:INSTALL_SURPRISE_PACK
call :DOWNLOAD_FILES Install-BigYeet.ps1
if errorlevel 1 exit /b 1
call :DOWNLOAD_FILES Install-BigDart.ps1
if errorlevel 1 exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\Install-BigYeet.ps1" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1"
if errorlevel 1 exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\Install-BigDart.ps1" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1"
exit /b %errorlevel%

:UNINSTALL_SURPRISE_PACK
call :DOWNLOAD_FILES Uninstall-BigYeet.ps1
if errorlevel 1 exit /b 1
call :DOWNLOAD_FILES Uninstall-BigDart.ps1
if errorlevel 1 exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\Uninstall-BigYeet.ps1" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1"
if errorlevel 1 exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\Uninstall-BigDart.ps1" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1"
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
