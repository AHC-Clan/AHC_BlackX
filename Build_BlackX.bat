@echo off
echo ============================================
echo   AHC_BlackX DLL Build
echo ============================================
echo.

:: Find Visual Studio with C++ build tools
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo [ERROR] Visual Studio not found.
    echo         Please install Visual Studio 2019 or later.
    pause
    exit /b 1
)

:: Find VS with C++ workload (requires vcvarsall.bat)
set "VS_PATH="
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VS_PATH=%%i"

:: Fallback: try all VS installations and pick one with vcvarsall.bat
if not defined VS_PATH (
    for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -all -property installationPath`) do (
        if not defined VS_PATH (
            if exist "%%i\VC\Auxiliary\Build\vcvarsall.bat" set "VS_PATH=%%i"
        )
    )
)

if not defined VS_PATH (
    echo [ERROR] No Visual Studio with C++ build tools found.
    echo         Please install "Desktop development with C++" workload.
    pause
    exit /b 1
)

echo [INFO] Visual Studio: %VS_PATH%
echo.

:: Setup x64 build environment
echo [1/3] Setting up x64 environment...
if not exist "%VS_PATH%\VC\Auxiliary\Build\vcvarsall.bat" (
    echo [ERROR] vcvarsall.bat not found.
    echo         Please install "Desktop development with C++" workload.
    pause
    exit /b 1
)
call "%VS_PATH%\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to setup build environment.
    pause
    exit /b 1
)
echo.

:: Build with MSBuild
echo [2/3] Building... (Release x64)
msbuild "%~dp0dll\AHC_BlackX.vcxproj" /p:Configuration=Release /p:Platform=x64 /verbosity:minimal
if %errorlevel% neq 0 (
    echo [ERROR] Build failed.
    pause
    exit /b 1
)
echo.

:: Copy to addons folder
set "DLL_PATH=%~dp0dll\x64\Release\AHC_BlackX_x64.dll"
if exist "%DLL_PATH%" (
    copy /Y "%DLL_PATH%" "%~dp0addons\AHC_BlackX_x64.dll" >nul
    echo [3/3] Build succeeded!
    echo.
    echo   Output: %~dp0addons\AHC_BlackX_x64.dll
    echo.
    echo ============================================
    echo   DLL has been placed in addons\ folder.
    echo   Deploy the addons\ folder contents to
    echo   @AHC_Addon\ or Arma 3 game root.
    echo ============================================
) else (
    echo [ERROR] DLL file not found.
    pause
    exit /b 1
)

echo.
pause
