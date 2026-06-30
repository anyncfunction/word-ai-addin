param(
  [switch]$NoBuild,
  [switch]$HttpFallback
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $root

Write-Host "🤖 AI 写作助手 - 永久安装" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# 1. 安装依赖
Write-Host "📦 安装依赖..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) { Write-Host "❌ 失败！" -ForegroundColor Red; exit 1 }
Write-Host "✅ 完成" -ForegroundColor Green

# 2. 构建
if (-not $NoBuild) {
  Write-Host "📦 构建项目..." -ForegroundColor Yellow
  npm run build
  if ($LASTEXITCODE -ne 0) { Write-Host "❌ 失败！" -ForegroundColor Red; exit 1 }
  Write-Host "✅ 完成" -ForegroundColor Green
}

# 3. 注册到 Word（永久生效）
Write-Host "🔧 注册加载项到 Word..." -ForegroundColor Yellow
$manifestUrl = if ($HttpFallback) { "http://localhost:3000/manifest.xml" } else { "http://localhost:3000/manifest.xml" }
& ".\register-addin.ps1" -ManifestUrl $manifestUrl

# 4. 添加开机自启（通过 VBS 静默启动，无窗口无弹窗）
Write-Host "🚀 设置开机自启..." -ForegroundColor Yellow
$startupDir = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startupDir "AI写作助手.lnk"

$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "$env:windir\System32\wscript.exe"
$shortcut.Arguments = "`"$root\start-server.vbs`" //B //NoLogo"
$shortcut.WorkingDirectory = "$root"
$shortcut.WindowStyle = 7
$shortcut.Description = "AI 写作助手 - 后台服务器（开机自启）"
$shortcut.Save()

Write-Host "✅ 开机自启已添加: $shortcutPath" -ForegroundColor Green

# 5. 立即启动服务器（静默）
Write-Host "🚀 启动服务器..." -ForegroundColor Yellow
$wshell = New-Object -ComObject WScript.Shell
$wshell.Run("node `"$root\server.cjs`"", 0, $false)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ 永久安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📌 已注册到 Word 注册表" -ForegroundColor Gray
Write-Host "📌 已添加开机自启（wscript.exe 静默启动，完全无感）" -ForegroundColor Gray
Write-Host ""
Write-Host "👉 现在打开 Word 就能看到「AI 写作助手」标签！" -ForegroundColor Cyan
Write-Host ""
Write-Host "🛑 卸载方式：双击 uninstall-permanent.ps1" -ForegroundColor Yellow
