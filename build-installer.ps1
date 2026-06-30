param(
  [switch]$NoSea,
  [switch]$SkipInstaller
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $root
$ErrorActionPreference = "Stop"

Write-Host "=== AI Writing Assistant - Build Installer ===" -ForegroundColor Cyan

# 1. Frontend
Write-Host "[1/3] Building frontend..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) { throw "Frontend build failed" }
Write-Host "OK" -ForegroundColor Green

# 2. SEA executable
if (-not $NoSea) {
  Write-Host "[2/3] Building server EXE..." -ForegroundColor Yellow
  if (Test-Path "sea-prep.blob") { Remove-Item "sea-prep.blob" -Force }
  node --experimental-sea-config sea-config.json 2>&1 | Out-Null
  $nodePath = (Get-Command node).Source
  Copy-Item -Path $nodePath -Destination "dist\ai-word-server.exe" -Force
  npx postject "dist\ai-word-server.exe" NODE_SEA_BLOB sea-prep.blob --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 2>&1 | Out-Null
  $sizeMB = [math]::Round((Get-Item "dist\ai-word-server.exe").Length / 1MB, 1)
  Write-Host "OK ($sizeMB MB)" -ForegroundColor Green
}

# 3. Find ISCC (Inno Setup Compiler)
if (-not $SkipInstaller) {
  Write-Host "[3/3] Finding Inno Setup..." -ForegroundColor Yellow

  $iscc = $null
  $searchPaths = @(
    Join-Path $root ".ispp"
    "C:\ispp"
    "${env:ProgramFiles}\Inno Setup 6"
    "${env:ProgramFiles(x86)}\Inno Setup 6"
    "${env:LOCALAPPDATA}\Programs\Inno Setup 6"
  )

  # Search known directories (non-recursive, fast)
  foreach ($dir in $searchPaths) {
    $candidate = Join-Path $dir "ISCC.exe"
    if (Test-Path $candidate) { $iscc = $candidate; break }
  }

  # Fallback: recursive search (slow but thorough)
  if (-not $iscc) {
    $extraPaths = @(
      "${env:ProgramFiles}\Inno*",
      "${env:ProgramFiles(x86)}\Inno*",
      "${env:LOCALAPPDATA}\Programs\Inno*"
    )
    foreach ($pattern in $extraPaths) {
      $dirs = Get-ChildItem $pattern -ErrorAction SilentlyContinue
      foreach ($d in $dirs) {
        $candidate = Join-Path $d.FullName "ISCC.exe"
        if (Test-Path $candidate) { $iscc = $candidate; break }
      }
      if ($iscc) { break }
    }
  }

  if (-not $iscc) {
    Write-Host "Inno Setup not found. Installing..." -ForegroundColor Yellow
    Write-Host "Downloading from jrsoftware.org..." -ForegroundColor Yellow
    $isppDir = Join-Path $root ".ispp"
    New-Item -ItemType Directory -Path $isppDir -Force | Out-Null

    # Try multiple URLs
    $urls = @(
      "https://jrsoftware.org/download.php/is.exe"
      "https://github.com/jrsoftware/issrc/releases/download/is-6_7_3/innosetup-6.7.3.exe"
      "https://objects.githubusercontent.com/github-production-release-asset-2e65be/15119627/5c50a7fb-ef49-43f3-925c-2ff6b38ac5b2"
    )

    $downloaded = $false
    $tmpPath = Join-Path $env:TEMP "innosetup.exe"
    foreach ($url in $urls) {
      try {
        Write-Host "  Trying: $url"
        Invoke-WebRequest -Uri $url -OutFile $tmpPath -UseBasicParsing -TimeoutSec 30
        if ((Get-Item $tmpPath).Length -gt 1MB) { $downloaded = $true; break }
      } catch { continue }
    }

    if ($downloaded) {
      Start-Process -FilePath $tmpPath -ArgumentList "/VERYSILENT /DIR=`"$isppDir`" /SUPPRESSMSGBOXES /NORESTART /NOICONS" -Wait
      Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
      $iscc = Join-Path $isppDir "ISCC.exe"
    }

    if (-not (Test-Path $iscc)) {
      Write-Host "Inno Setup download failed (network may be blocked)." -ForegroundColor Red
      Write-Host "Install manually: https://jrsoftware.org/isdl.php" -ForegroundColor Yellow
      Write-Host "Or use winget: winget install JRSoftware.InnoSetup" -ForegroundColor Yellow
      Write-Host "Then re-run this script." -ForegroundColor Yellow
      Write-Host ""
      Write-Host "Server EXE already built at: dist\ai-word-server.exe" -ForegroundColor Green
      Write-Host "You can also use the manual install scripts:" -ForegroundColor Green
      Write-Host "  .\install-permanent.ps1" -ForegroundColor Gray
      exit 0
    }
  }

  Write-Host "ISCC: $iscc" -ForegroundColor Green

  # 4. Compile
  Write-Host "[4/4] Compiling installer..." -ForegroundColor Yellow
  if (Test-Path "output") { Remove-Item -Recurse -Force "output" }
  & $iscc "installer.iss"
  if ($LASTEXITCODE -ne 0) { throw "Installer compilation failed" }
  Write-Host "OK" -ForegroundColor Green

  # 5. Result
  Get-ChildItem "output" -Filter "*.exe" | ForEach-Object {
    $sizeMB = [math]::Round($_.Length / 1MB, 2)
    Write-Host "Output: $($_.Name) ($sizeMB MB)" -ForegroundColor White
    Write-Host "  Path: $($_.FullName)" -ForegroundColor Gray
  }
} else {
  Write-Host "SkipInstaller flag set. Server EXE ready at: dist\ai-word-server.exe" -ForegroundColor Green
}

Write-Host "=== Done ===" -ForegroundColor Cyan
