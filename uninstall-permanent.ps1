$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "🛑 卸载 AI 写作助手..." -ForegroundColor Cyan

# 1. 移除开机自启
$startupDir = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startupDir "AI写作助手.lnk"
if (Test-Path $shortcutPath) {
  Remove-Item $shortcutPath -Force
  Write-Host "✅ 已移除开机自启" -ForegroundColor Green
}

# 2. 停掉正在运行的服务器
Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
  $_.CommandLine -like "*server.cjs*"
} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "✅ 已停止服务器" -ForegroundColor Green

# 3. 从 Word 注册表卸载
& ".\unregister-addin.ps1"

Write-Host ""
Write-Host "✅ 已完全卸载" -ForegroundColor Green
