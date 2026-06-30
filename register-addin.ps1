param(
  [string]$ManifestUrl = "http://localhost:3000/manifest.xml"
)

$addinName = "WordAiAddin"
$regPath = "HKCU:\Software\Microsoft\Office\Word\Addins\$addinName"
$officeVer = "16.0"  # Office 2016/365

Write-Host "🔧 注册 Word 加载项..." -ForegroundColor Cyan

# 创建加载项注册表项
if (-not (Test-Path $regPath)) {
  New-Item -Path $regPath -Force | Out-Null
}

Set-ItemProperty -Path $regPath -Name "FriendlyName" -Value "AI 写作助手"
Set-ItemProperty -Path $regPath -Name "Description" -Value "AI 驱动的 Word 文档生成插件，支持续写、改写、全文生成"
Set-ItemProperty -Path $regPath -Name "Manifest" -Value $ManifestUrl
Set-ItemProperty -Path $regPath -Name "LoadBehavior" -Value 3
Set-ItemProperty -Path $regPath -Name "ProviderName" -Value "AI Word"

# 如果是 HTTP，配置 Office 允许 HTTP 加载项
if ($ManifestUrl -like "http://*") {
  $internetPath = "HKCU:\Software\Microsoft\Office\$officeVer\Common\Internet"
  if (-not (Test-Path $internetPath)) {
    New-Item -Path $internetPath -Force | Out-Null
  }
  Set-ItemProperty -Path $internetPath -Name "CreateObjectWhistlist" -Value ([int]0x80000001) -Type DWord
  Write-Host "⚠️  已配置 Office 允许 HTTP 加载项（调试模式）" -ForegroundColor Yellow
}

Write-Host "✅ 注册成功！" -ForegroundColor Green
Write-Host "📋 manifest: $ManifestUrl" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 启动方式：双击 start-addin.bat 一键启动" -ForegroundColor Yellow
Write-Host "💡 卸载方式：双击 unregister-addin.ps1" -ForegroundColor Yellow
