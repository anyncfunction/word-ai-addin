# 需要管理员权限运行！
# 生成自签名证书用于 HTTPS

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$certDir = Join-Path $root ".certs"

if (-not (Test-Path $certDir)) { New-Item -ItemType Directory -Path $certDir -Force | Out-Null }

# 检查是否已有证书
$keyPath = Join-Path $certDir "localhost.key"
$certPath = Join-Path $certDir "localhost.crt"
if (Test-Path $keyPath -and (Test-Path $certPath)) {
  Write-Host "✅ 证书已存在" -ForegroundColor Green
  exit 0
}

Write-Host "🔐 生成自签名证书..." -ForegroundColor Yellow

try {
  # 用 PowerShell 生成自签名证书（需要管理员）
  $cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(10) -KeyAlgorithm RSA -KeyLength 2048
  $certThumbprint = $cert.Thumbprint

  # 导出证书
  $pwd = ConvertTo-SecureString -String "aiquick" -Force -AsPlainText
  $pfxPath = Join-Path $certDir "localhost.pfx"
  Export-PfxCertificate -Cert "cert:\LocalMachine\My\$certThumbprint" -FilePath $pfxPath -Password $pwd | Out-Null

  # 导出为 CRT 和 KEY 格式
  $rsaCert = Get-Item "cert:\LocalMachine\My\$certThumbprint"
  $certBytes = $rsaCert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
  [System.IO.File]::WriteAllBytes($certPath, $certBytes)

  # 提取私钥（需要 openssl）
  $openssl = Get-Command "openssl" -ErrorAction SilentlyContinue
  if ($openssl) {
    & openssl pkcs12 -in $pfxPath -nocerts -nodes -password pass:aiquick -out $keyPath 2>$null
    Write-Host "✅ 证书生成完成！" -ForegroundColor Green
  } else {
    Write-Host "⚠️  未找到 openssl，已导出 PFX 格式" -ForegroundColor Yellow
    Write-Host "   手动提取私钥: openssl pkcs12 -in .certs\\localhost.pfx -nocerts -nodes -out .certs\\localhost.key" -ForegroundColor Gray
  }

  # 信任证书（安装到受信任根目录）
  $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
  $store.Open("ReadWrite")
  $store.Add($rsaCert)
  $store.Close()
  Write-Host "✅ 证书已添加到受信任根目录" -ForegroundColor Green

} catch {
  Write-Host "❌ 证书生成失败: $_" -ForegroundColor Red
  Write-Host ""
  Write-Host "请尝试以下任一方式：" -ForegroundColor Yellow
  Write-Host "1. 以管理员身份重新运行此脚本" -ForegroundColor Gray
  Write-Host "2. 使用 start-addin.bat 以 HTTP 模式运行（Word Online 可用）" -ForegroundColor Gray
}
