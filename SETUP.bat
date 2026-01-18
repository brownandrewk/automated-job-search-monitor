@echo off
REM OpportunityAlert - Setup Launcher
REM This handles PowerShell execution policy and runs the installer

echo ============================================
echo    OPPORTUNITYALERT
echo    Setup Launcher
echo ============================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell is not installed or not in PATH.
    echo Please install PowerShell and try again.
    pause
    exit /b 1
)

echo Checking PowerShell execution policy...
echo.

REM Try to run the installer with execution policy bypass
echo Running installer...
echo.

PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0INSTALL.ps1"

REM Check if installer ran successfully
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo Setup completed successfully!
    echo ============================================
) else (
    echo.
    echo ============================================
    echo Setup encountered an error.
    echo ============================================
    echo.
    echo If you see an error about execution policy:
    echo 1. Open PowerShell as Administrator
    echo 2. Run: Set-ExecutionPolicy RemoteSigned
    echo 3. Type Y and press Enter
    echo 4. Run this SETUP.bat again
)

echo.
pause
