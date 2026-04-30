@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false; " ^
  "function U($s) { [Text.RegularExpressions.Regex]::Unescape($s) }; " ^
  "if (-not (Test-Path -LiteralPath 'config.json')) { Write-Host (U '\u005b\u9519\u8bef\u005d \u627e\u4e0d\u5230 config.json\u3002'); exit 1 }; " ^
  "try { $cfg = Get-Content -Raw 'config.json' | ConvertFrom-Json } catch { Write-Host ((U '\u005b\u9519\u8bef\u005d \u914d\u7f6e\u6587\u4ef6\u89e3\u6790\u5931\u8d25\uff1a') + $_.Exception.Message); exit 1 }; " ^
  "$port = [int]$cfg.server.port; " ^
  "$items = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue; " ^
  "if (-not $items) { Write-Host ((U '\u7aef\u53e3 ') + $port + (U ' \u5f53\u524d\u6ca1\u6709\u76d1\u542c\u8fdb\u7a0b\u3002')); exit 0 }; " ^
  "$items | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { Write-Host ((U '\u6b63\u5728\u505c\u6b62 PID ') + $_ + (U ' \uff0c\u7aef\u53e3 ') + $port); Stop-Process -Id $_ -Force }"

echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false; " ^
  "Write-Host ([Text.RegularExpressions.Regex]::Unescape('\u6309\u4efb\u610f\u952e\u9000\u51fa...')) -NoNewline"
pause >nul
