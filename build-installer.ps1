param([switch]$NoSea)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $root
$ErrorActionPreference = "Stop"

Write-Host "=== AI Writing Assistant - Build Installer ===" -ForegroundColor Cyan

# 1. Build frontend
Write-Host "[1/5] Building frontend..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) { throw "Frontend build failed" }
Write-Host "OK" -ForegroundColor Green

# 2. Build SEA executable
if (-not $NoSea) {
  Write-Host "[2/5] Building server EXE..." -ForegroundColor Yellow
  if (Test-Path "sea-prep.blob") { Remove-Item "sea-prep.blob" -Force }
  node --experimental-sea-config sea-config.json 2>&1 | Out-Null
  $nodePath = (Get-Command node).Source
  Copy-Item -Path $nodePath -Destination "dist\ai-word-server.exe" -Force
  npx postject "dist\ai-word-server.exe" NODE_SEA_BLOB sea-prep.blob --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 2>&1 | Out-Null
  $sizeMB = [math]::Round((Get-Item "dist\ai-word-server.exe").Length / 1MB, 1)
  Write-Host "OK ($sizeMB MB)" -ForegroundColor Green
}

# 3. Download Inno Setup
Write-Host "[3/5] Checking Inno Setup..." -ForegroundColor Yellow
$isppDir = Join-Path $root ".ispp"
$iscc = Get-ChildItem -Path $isppDir -Recurse -Filter "ISCC.exe" | Select-Object -First 1 -ExpandProperty FullName

if (-not $iscc) {
  Write-Host "Downloading Inno Setup Portable..." -ForegroundColor Yellow
  if (-not (Test-Path $isppDir)) { New-Item -ItemType Directory -Path $isppDir -Force | Out-Null }
  $url = "https://github.com/jrsoftware/issrc/releases/download/v6.4.2/innosetup-6.4.2.exe"
  $tmpPath = Join-Path $env:TEMP "innosetup.exe"
  try {
    Invoke-WebRequest -Uri $url -OutFile $tmpPath -UseBasicParsing
    Start-Process -FilePath $tmpPath -ArgumentList "/VERYSILENT /DIR=`"$isppDir`" /SUPPRESSMSGBOXES /NORESTART" -Wait
    Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
    $iscc = Get-ChildItem -Path $isppDir -Recurse -Filter "ISCC.exe" | Select-Object -First 1 -ExpandProperty FullName
  } catch {
    Write-Host "Download failed: $_" -ForegroundColor Yellow
    Write-Host "Install Inno Setup 6.x manually from https://jrsoftware.org/isdl.php" -ForegroundColor Yellow
    throw "Inno Setup not found"
  }
}
Write-Host "OK: $iscc" -ForegroundColor Green

# 4. Compile installer
Write-Host "[4/5] Compiling installer..." -ForegroundColor Yellow
if (Test-Path "output") { Remove-Item -Recurse -Force "output" }
& $iscc "installer.iss"
if ($LASTEXITCODE -ne 0) { throw "Installer compilation failed" }
Write-Host "OK" -ForegroundColor Green

# 5. Show result
$setupFiles = Get-ChildItem -Path (Join-Path $root "output") -Filter "*.exe"
Write-Host "=== Done ===" -ForegroundColor Cyan
foreach ($f in $setupFiles) {
  $sizeMB = [math]::Round($f.Length / 1MB, 2)
  Write-Host "Output: $($f.Name) ($sizeMB MB)" -ForegroundColor White
  Write-Host "  Path: $($f.FullName)" -ForegroundColor Gray
}
