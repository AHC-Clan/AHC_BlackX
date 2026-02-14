@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo ============================================
echo   AHC_BlackX Git Manager
echo ============================================
echo.
echo   [0] Commit All
echo   [1] Commit All (exclude AHC_BlackX.txt)
echo   [2] Commit AHC_BlackX.txt only
echo   [3] Reset to remote (discard local changes)
echo.
set /p "choice=Select [0-3]: "

if "%choice%"=="0" goto :COMMIT_ALL
if "%choice%"=="1" goto :COMMIT_EXCLUDE
if "%choice%"=="2" goto :COMMIT_KEY_ONLY
if "%choice%"=="3" goto :RESET_REMOTE

echo [ERROR] Invalid input: %choice%
pause
exit /b 1

:COMMIT_ALL
echo.
set /p "msg=Commit message: "
if "%msg%"=="" (
    echo [ERROR] Commit message is required.
    pause
    exit /b 1
)
git add -A
git commit -m "%msg%"
if %errorlevel% neq 0 (
    echo [ERROR] Commit failed.
    pause
    exit /b 1
)
git push origin main
if %errorlevel% neq 0 (
    echo [ERROR] Push failed.
    pause
    exit /b 1
)
echo.
echo [OK] All files committed and pushed.
pause
exit /b 0

:COMMIT_EXCLUDE
echo.
set /p "msg=Commit message: "
if "%msg%"=="" (
    echo [ERROR] Commit message is required.
    pause
    exit /b 1
)
git add -A
git reset HEAD AHC_BlackX.txt >nul 2>&1
git commit -m "%msg%"
if %errorlevel% neq 0 (
    echo [ERROR] Commit failed.
    pause
    exit /b 1
)
git push origin main
if %errorlevel% neq 0 (
    echo [ERROR] Push failed.
    pause
    exit /b 1
)
echo.
echo [OK] Committed and pushed (AHC_BlackX.txt excluded).
pause
exit /b 0

:COMMIT_KEY_ONLY
echo.
set /p "msg=Commit message: "
if "%msg%"=="" (
    echo [ERROR] Commit message is required.
    pause
    exit /b 1
)
git add AHC_BlackX.txt
git commit -m "%msg%"
if %errorlevel% neq 0 (
    echo [ERROR] Commit failed.
    pause
    exit /b 1
)
git push origin main
if %errorlevel% neq 0 (
    echo [ERROR] Push failed.
    pause
    exit /b 1
)
echo.
echo [OK] AHC_BlackX.txt committed and pushed.
pause
exit /b 0

:RESET_REMOTE
echo.
echo ============================================
echo   WARNING: All local changes will be lost!
echo ============================================
echo.
set /p "confirm=Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
    echo Cancelled.
    pause
    exit /b 0
)
git fetch origin
git reset --hard origin/main
if %errorlevel% neq 0 (
    echo [ERROR] Reset failed.
    pause
    exit /b 1
)
echo.
echo [OK] Reset to remote origin/main.
pause
exit /b 0
