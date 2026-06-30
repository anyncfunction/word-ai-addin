param(
  [switch]$NoBuild,
  [switch]$NoWord
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $root

Write-Host "🤖 AI 写作助手 - Word 加载项启动器" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# 1. 构建
if (-not $NoBuild) {
  Write-Host "📦 构建项目..." -ForegroundColor Yellow
  npm run build
  if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 构建失败！" -ForegroundColor Red
    exit 1
  }
  Write-Host "✅ 构建完成" -ForegroundColor Green
}

# 2. 注册到注册表
Write-Host "🔧 注册加载项到 Word..." -ForegroundColor Yellow
& ".\register-addin.ps1"

# 3. 启动服务器（新窗口）
Write-Host "🚀 启动本地服务器..." -ForegroundColor Yellow
$serverJob = Start-Job -ScriptBlock {
  param($dir)
  Set-Location -LiteralPath $dir
  node server.cjs
} -ArgumentList $root

Write-Host "✅ 服务器已在后台启动 (localhost:3000)" -ForegroundColor Green

# 4. 打开 Word
if (-not $NoWord) {
  Write-Host "📄 正在打开 Word..." -ForegroundColor Yellow
  Start-Process "WINWORD.EXE"
}

Write-Host ""
Write-Host "✨ AI 写作助手已就绪！打开 Word 即可在工具栏看到「AI 写作助手」标签。" -ForegroundColor Green
Write-Host ""
Write-Host "按 Enter 键停止服务器并退出..."
Read-Host

# 清理
Stop-Job $serverJob
Remove-Job $serverJob
Write-Host "👋 已停止" -ForegroundColor Cyan
