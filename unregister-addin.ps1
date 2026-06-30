$addinName = "WordAiAddin"
$regPath = "HKCU:\Software\Microsoft\Office\Word\Addins\$addinName"

if (Test-Path $regPath) {
  Remove-Item -Path $regPath -Recurse -Force
  Write-Host "✅ 已卸载 AI 写作助手加载项" -ForegroundColor Green
} else {
  Write-Host "⚠️  加载项未注册" -ForegroundColor Yellow
}
