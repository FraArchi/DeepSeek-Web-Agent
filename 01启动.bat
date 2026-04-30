@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

set "APP_DIR=%~dp0"
set "NODE_EXE=%~dp0node\node.exe"
if not exist "%NODE_EXE%" (
  set "NODE_EXE=node"
)
set "COUNTDOWN=5"

if not exist "%~dp0config.json" (
  echo [ERROR] config.json not found.
  pause
  exit /b 1
)

if not exist "%~dp0node_modules\playwright\package.json" (
  echo [ERROR] node_modules is incomplete. Please keep node_modules in this folder.
  pause
  exit /b 1
)

echo Starting DeepSeekWeb2API in background...
echo Config: %~dp0config.json
echo Logs: %~dp0logs
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$appDir = $env:APP_DIR; " ^
  "$node = $env:NODE_EXE; " ^
  "$script = Join-Path $appDir 'src\index.js'; " ^
  "$config = Join-Path $appDir 'config.json'; " ^
  "$logDir = Join-Path $appDir 'logs'; " ^
  "$cfg = Get-Content -Raw $config | ConvertFrom-Json; " ^
  "$port = [int]$cfg.server.port; " ^
  "$items = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue; " ^
  "if ($items) { Write-Host ('Port ' + $port + ' is already listening. Skip duplicate start.'); exit 2 }; " ^
  "New-Item -ItemType Directory -Force -Path $logDir | Out-Null; " ^
  "$outLog = Join-Path $logDir 'service.out.log'; " ^
  "$errLog = Join-Path $logDir 'service.err.log'; " ^
  "$argList = ([char]34) + $script + ([char]34); " ^
  "$p = Start-Process -FilePath $node -ArgumentList $argList -WorkingDirectory $appDir -WindowStyle Hidden -RedirectStandardOutput $outLog -RedirectStandardError $errLog -PassThru; " ^
  "Start-Sleep -Milliseconds 800; " ^
  "if ($p.HasExited) { Write-Host ('Background process exited immediately. See log: ' + $errLog); exit 1 }; " ^
  "Write-Host ('Background process started. PID: ' + $p.Id)"

if errorlevel 2 goto countdown
if errorlevel 1 (
  echo.
  echo [ERROR] Background start failed. Please check logs\service.err.log.
  pause
  exit /b 1
)

:countdown
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false; " ^
  "$count = [int]$env:COUNTDOWN; " ^
  "function U($s) { [Text.RegularExpressions.Regex]::Unescape($s) }; " ^
  "Write-Host ''; " ^
  "Write-Host ($count.ToString() + (U '\u79d2\u540e\u6b64\u7a97\u53e3\u81ea\u52a8\u5173\u95ed\uff0c\u7a0b\u5e8f\u5c06\u7ee7\u7eed\u5728\u540e\u53f0\u8fd0\u884c\u3002')); " ^
  "Write-Host (U '\u5982\u9700\u5173\u95ed\uff0c\u8bf7\u6267\u884c\u505c\u6b62\u811a\u672c\u3002'); " ^
  "Write-Host ''; " ^
  "for ($i = $count; $i -ge 1; $i--) { Write-Host ($i.ToString() + (U '\u79d2\u540e\u5173\u95ed...')); Start-Sleep -Seconds 1 }"

echo.
exit /b 0
