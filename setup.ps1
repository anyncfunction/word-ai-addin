param(
  [switch]$NoBuild
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $root

Write-Host "🤖 AI 写作助手 - 一键安装" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# 1. 安装依赖
Write-Host "📦 安装依赖..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
  Write-Host "❌ 依赖安装失败！" -ForegroundColor Red
  exit 1
}
Write-Host "✅ 依赖安装完成" -ForegroundColor Green

# 2. 构建
if (-not $NoBuild) {
  Write-Host "📦 构建项目..." -ForegroundColor Yellow
  npm run build
  if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 构建失败！" -ForegroundColor Red
    exit 1
  }
  Write-Host "✅ 构建完成" -ForegroundColor Green
}

# 3. 注册加载项
Write-Host "🔧 注册加载项..." -ForegroundColor Yellow
& ".\register-addin.ps1"

Write-Host ""
Write-Host "✅ 安装完成！" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 启动方式：双击 start-addin.bat 或运行 start-addin.ps1" -ForegroundColor Cyan
Write-Host "   脚本会自动：构建 → 启动服务器 → 打开 Word" -ForegroundColor Gray
Write-Host ""
Write-Host "🛑 停止方式：关闭启动脚本窗口即可" -ForegroundColor Gray
