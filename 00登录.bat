@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

set "NODE_EXE=%~dp0node\node.exe"
if not exist "%NODE_EXE%" (
  set "NODE_EXE=node"
)

if not exist "%~dp0config.json" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false; " ^
    "Write-Host ([Text.RegularExpressions.Regex]::Unescape('\u005b\u9519\u8bef\u005d \u627e\u4e0d\u5230 config.json\u3002'))"
  echo.
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false; " ^
    "Write-Host ([Text.RegularExpressions.Regex]::Unescape('\u6309\u4efb\u610f\u952e\u9000\u51fa...')) -NoNewline"
  pause >nul
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false; " ^
  "function U($s) { [Text.RegularExpressions.Regex]::Unescape($s) }; " ^
  "Write-Host (U '\u6b63\u5728\u6253\u5f00 DeepSeek \u767b\u5f55\u6d4f\u89c8\u5668...'); " ^
  "Write-Host (U '\u8bf7\u5728\u6d4f\u89c8\u5668\u7a97\u53e3\u5b8c\u6210\u767b\u5f55\uff0c\u5b8c\u6210\u540e\u53ef\u6309 Ctrl+C \u5173\u95ed\u6b64\u63a7\u5236\u53f0\u3002'); " ^
  "Write-Host ''"
"%NODE_EXE%" "%~dp0src\index.js" --login

echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false; " ^
  "Write-Host ([Text.RegularExpressions.Regex]::Unescape('\u6309\u4efb\u610f\u952e\u9000\u51fa...')) -NoNewline"
pause >nul
