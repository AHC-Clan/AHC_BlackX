param(
    [switch]$Auto
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$KeyFile = Join-Path $ScriptDir "AHC_BlackX.txt"
$MainCpp = Join-Path $ScriptDir "dll\src\main.cpp"
$BuildBat = Join-Path $ScriptDir "build.bat"

function Generate-Key {
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $part1 = -join (1..3 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    $part2 = -join (1..4 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    $part3 = -join (1..4 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    $part4 = -join (1..4 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return "$part1-$part2-$part3-$part4"
}

function Update-KeyFile($newKey) {
    Set-Content -Path $KeyFile -Value $newKey -NoNewline -Encoding UTF8
    Write-Host "[OK] AHC_BlackX.txt -> $newKey"
}

function Update-MainCppKey($newKey) {
    $content = Get-Content -Path $MainCpp -Raw -Encoding UTF8
    if ($content -match 'static const char\* EXPECTED_KEY = "([^"]+)"') {
        $oldKey = $Matches[1]
        $content = $content.Replace(
            "static const char* EXPECTED_KEY = `"$oldKey`"",
            "static const char* EXPECTED_KEY = `"$newKey`""
        )
        Set-Content -Path $MainCpp -Value $content -NoNewline -Encoding UTF8
        Write-Host "[OK] main.cpp EXPECTED_KEY -> $newKey"
    }
    else {
        Write-Host "[ERROR] EXPECTED_KEY not found in main.cpp"
        exit 1
    }
}

function Run-Build {
    Write-Host ""
    Write-Host "[BUILD] Running build.bat..."
    Push-Location $ScriptDir
    & cmd /c $BuildBat
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Build failed."
        Pop-Location
        exit 1
    }
    Pop-Location
    Write-Host "[OK] Build complete."
}

# === Main ===
$newKey = Generate-Key
$mode = $(if ($Auto) { "auto" } else { "manual" })

Write-Host ""
Write-Host "============================================"
Write-Host "  AHC_BlackX Key Renewal"
Write-Host "============================================"
Write-Host "  New Key : $newKey"
Write-Host "  Mode    : $mode"
Write-Host "============================================"
Write-Host ""

# 1. Update key files
Update-KeyFile $newKey
Update-MainCppKey $newKey

if ($Auto) {
    # 2. Commit + push
    Write-Host ""
    Write-Host "[GIT] Committing key change & push..."
    Push-Location $ScriptDir
    git add AHC_BlackX.txt dll/src/main.cpp
    git commit -m "Update auth key"
    git push origin main
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] git push failed."
        Pop-Location
        exit 1
    }
    Pop-Location
}

# 3. Build
Run-Build

Write-Host ""
Write-Host "============================================"
Write-Host "  Done!"
Write-Host "  Key: $newKey"
if (-not $Auto) {
    Write-Host ""
    Write-Host "  [NOTE] Manual mode."
    Write-Host "  After updating, run git commit/push manually."
}
Write-Host "============================================"
Write-Host ""
