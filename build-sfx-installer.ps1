param([switch]$NoSea)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $root
$ErrorActionPreference = "Stop"

Write-Host "=== AI Writing Assistant - Build SFX Installer ===" -ForegroundColor Cyan

# 1. Frontend
Write-Host "[1/3] Building frontend..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) { throw "Frontend build failed" }
Write-Host "OK" -ForegroundColor Green

# 2. SEA exe
if (-not $NoSea) {
  Write-Host "[2/3] Building server EXE..." -ForegroundColor Yellow
  if (Test-Path "sea-prep.blob") { Remove-Item "sea-prep.blob" -Force }
  node --experimental-sea-config sea-config.json 2>&1 | Out-Null
  $nodePath = (Get-Command node).Source
  Copy-Item $nodePath "dist\ai-word-server.exe" -Force
  npx postject "dist\ai-word-server.exe" NODE_SEA_BLOB sea-prep.blob --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 2>&1 | Out-Null
  $sizeMB = [math]::Round((Get-Item "dist\ai-word-server.exe").Length / 1MB, 1)
  Write-Host "OK ($sizeMB MB)" -ForegroundColor Green
}

# 3. Create install script that will be bundled
Write-Host "[3/3] Creating installer..." -ForegroundColor Yellow

$installDir = Join-Path $root ".install-tmp"
if (Test-Path $installDir) { Remove-Item -Recurse -Force $installDir }
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

# Copy all needed files
Copy-Item "dist\ai-word-server.exe" $installDir
Copy-Item "dist\src\index.html" (Join-Path $installDir "dist\src") -Force
New-Item -ItemType Directory -Path (Join-Path $installDir "dist\assets") -Force | Out-Null
Copy-Item "dist\assets\*" (Join-Path $installDir "dist\assets") -Force
New-Item -ItemType Directory -Path (Join-Path $installDir "assets") -Force | Out-Null
Copy-Item "assets\*" (Join-Path $installDir "assets") -Force
Copy-Item "manifest.xml" $installDir

# Create setup.bat (the installer script)
$setupBat = @'
@echo off
chcp 65001 >nul
title AI Writing Assistant Installer

echo Installing AI Writing Assistant...
echo.

set "INSTALL_DIR=%LOCALAPPDATA%\AI-Word-Addin"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo Copying files...
xcopy /E /I /Y "%~dp0dist" "%INSTALL_DIR%\dist" >nul
xcopy /E /I /Y "%~dp0assets" "%INSTALL_DIR%\assets" >nul
copy /Y "%~dp0ai-word-server.exe" "%INSTALL_DIR%\" >nul
copy /Y "%~dp0manifest.xml" "%INSTALL_DIR%\" >nul

echo Registering Word add-in...
reg add "HKCU\Software\Microsoft\Office\Word\Addins\WordAiAddin" /v FriendlyName /t REG_SZ /d "AI Writing Assistant" /f >nul
reg add "HKCU\Software\Microsoft\Office\Word\Addins\WordAiAddin" /v Description /t REG_SZ /d "AI-powered Word document generator" /f >nul
reg add "HKCU\Software\Microsoft\Office\Word\Addins\WordAiAddin" /v Manifest /t REG_SZ /d "http://localhost:3000/manifest.xml" /f >nul
reg add "HKCU\Software\Microsoft\Office\Word\Addins\WordAiAddin" /v LoadBehavior /t REG_DWORD /d 3 /f >nul
reg add "HKCU\Software\Microsoft\Office\Word\Addins\WordAiAddin" /v ProviderName /t REG_SZ /d "AI Word" /f >nul
reg add "HKCU\Software\Microsoft\Office\16.0\Common\Internet" /v CreateObjectWhistlist /t REG_DWORD /d 2147483649 /f >nul

echo Adding startup entry...
powershell -Command "$s=[Environment]::GetFolderPath('Startup');$w=New-Object -ComObject WScript.Shell;$s=$w.CreateShortcut(\"$s\\AI Writing Assistant.lnk\");$s.TargetPath='%INSTALL_DIR%\ai-word-server.exe';$s.WorkingDirectory='%INSTALL_DIR%';$s.WindowStyle=7;$s.Save()" >nul

echo Starting server...
start /min "" "%INSTALL_DIR%\ai-word-server.exe"

echo Starting Word...
start "" WINWORD.EXE

echo.
echo ========================================
echo   Installation complete!
echo   Open Word to see the AI Writing Assistant
echo ========================================
echo.
pause
'@

$setupBat | Set-Content (Join-Path $installDir "setup.bat") -Encoding ASCII

# Create SED file for IExpress
$sedContent = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_MaxSize=0
ContainedFiles="setup.bat" "ai-word-server.exe" "manifest.xml" "dist\src\index.html" "dist\assets\index-VMn-bXQd.css" "dist\assets\index-xjwozV24.js" "assets\icon-32.svg" "assets\icon-80.svg"
[SourceFiles]
SourceFilesRoot=INSTALLDIR
[SourceFile0]
SourceFile=setup.bat
[SourceFile1]
SourceFile=ai-word-server.exe
[SourceFile2]
SourceFile=manifest.xml
[SourceFile3]
SourceFile=dist\src\index.html
[SourceFile4]
SourceFile=dist\assets\index-VMn-bXQd.css
[SourceFile5]
SourceFile=dist\assets\index-xjwozV24.js
[SourceFile6]
SourceFile=assets\icon-32.svg
[SourceFile7]
SourceFile=assets\icon-80.svg
[Strings]
AppLaunched=setup.bat
PostInstallCmd=<None>
AdminQuietInstCmd=<None>
QuietInstCmd=<None>
CustomInfo=
ParentWinTitle=AI Writing Assistant Installer
ParentWndCaption=AI Writing Assistant
AppName=AI Writing Assistant
AppVersion=1.0.0
"@

# Write SED file
$sedPath = Join-Path $root "installer.sed"
$sedContent | Set-Content $sedPath -Encoding ASCII

# Clean up
Remove-Item -Recurse -Force $installDir

Write-Host "SED file created at: installer.sed" -ForegroundColor Green
Write-Host ""
Write-Host "=== Build complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "To create the final EXE installer:" -ForegroundColor Yellow
Write-Host "  1. Run: iexpress /N installer.sed" -ForegroundColor White
Write-Host "  2. The IExpress wizard will open" -ForegroundColor Gray
Write-Host "  3. Follow the prompts (all defaults are fine)" -ForegroundColor Gray
Write-Host ""
Write-Host "Or just use the InnoSetup installer if you have it:" -ForegroundColor Yellow
Write-Host "  C:\ispp\ISCC.exe installer.iss" -ForegroundColor White
