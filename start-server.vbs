' AI 写作助手 - 后台静默启动服务器
' Windows 启动时自动运行，无窗口无弹窗

Dim shell, nodePath, scriptPath
Set shell = CreateObject("WScript.Shell")

' 获取本脚本所在目录
scriptPath = CreateObject("Scripting.FileSystemObject").GetFile(WScript.ScriptFullName).ParentFolder.Path

' 静默启动 node server.cjs（0 = 隐藏窗口）
shell.Run "node """ & scriptPath & "\server.cjs""", 0, False

Set shell = Nothing
