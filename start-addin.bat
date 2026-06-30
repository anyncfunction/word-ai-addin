@echo off
chcp 65001 >nul
title AI 写作助手

echo 🤖 AI 写作助手 - Word 加载项
echo ===================================
echo.

cd /d "%~dp0"

echo 📦 构建项目...
call npm run build
if %errorlevel% neq 0 (
  echo ❌ 构建失败！
  pause
  exit /b 1
)
echo ✅ 构建完成
echo.

echo 🔧 注册加载项到 Word...
powershell -ExecutionPolicy Bypass -File "register-addin.ps1"
echo.

echo 🚀 启动本地服务器...
start "AI Word Server" /min cmd /c "node server.cjs"
echo ✅ 服务器已启动 ^(localhost:3000^)
echo.

echo 📄 正在打开 Word...
start WINWORD.EXE
echo.

echo ✨ AI 写作助手已就绪！
echo 关闭本窗口即可停止服务器。
echo.

pause
