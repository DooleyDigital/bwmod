@echo off
setlocal EnableExtensions
title Update BigYeet Throw Strength

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

cls
echo ==================================================
echo          UPDATE BIGYEET THROW STRENGTH
echo ==================================================
echo.
echo This updater will find Big Walk automatically and
echo change only BigYeet's player throw multiplier.
echo.

if not exist "%BIGWALK_TEMP_DIR%" mkdir "%BIGWALK_TEMP_DIR%" >nul 2>&1

echo Downloading the latest updater from GitHub...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri ($env:BIGWALK_RAW_BASE + '/scripts/Common.ps1') -OutFile (Join-Path $env:BIGWALK_TEMP_DIR 'Common.ps1'); Invoke-WebRequest -UseBasicParsing -Uri ($env:BIGWALK_RAW_BASE + '/scripts/Update-BigYeet-Throw.ps1') -OutFile (Join-Path $env:BIGWALK_TEMP_DIR 'Update-BigYeet-Throw.ps1')"

if errorlevel 1 (
    echo.
    echo ERROR: The updater could not be downloaded from GitHub.
    echo Check your internet connection and try again.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%BIGWALK_TEMP_DIR%\Update-BigYeet-Throw.ps1" -CommonPath "%BIGWALK_TEMP_DIR%\Common.ps1"
set "UPDATE_RESULT=%errorlevel%"

echo.
pause
exit /b %UPDATE_RESULT%
