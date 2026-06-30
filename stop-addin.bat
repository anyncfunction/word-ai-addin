@echo off
chcp 65001 >nul
title 停止 AI 写作助手

echo 🛑 正在停止 AI 写作助手服务器...
echo.

:: 杀掉 node server.cjs 进程
for /f "tokens=2 delims=," %%a in ('tasklist /fi "imagename eq node.exe" /fo csv /nh 2^>nul') do (
  taskkill /f /pid %%a >nul 2>&1
)

:: 清理注册表项（可选）
echo 是否也从 Word 中卸载加载项？(y/n)
set /p unreg=
if /i "%unreg%"=="y" (
  powershell -ExecutionPolicy Bypass -File "unregister-addin.ps1"
)

echo ✅ 已停止
pause
