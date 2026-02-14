@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo ============================================
echo   AHC_BlackX Key Generator
echo ============================================
echo.
echo   [0] Manual  - Change key + build only
echo   [1] Auto    - Change key + git push + build
echo.
set /p "choice=Select [0-1]: "

if "%choice%"=="0" (
    powershell -ExecutionPolicy Bypass -File "%~dp0tools\renew_key.ps1"
) else if "%choice%"=="1" (
    powershell -ExecutionPolicy Bypass -File "%~dp0tools\renew_key.ps1" -Auto
) else (
    echo [ERROR] Invalid input: %choice%
)

pause
