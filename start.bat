@echo off
rem Cascade Tribunal: one-click local start. Serves the API and the built interface on this machine only (127.0.0.1).
setlocal
cd /d "%~dp0"
if not defined CASCADE_PORT set CASCADE_PORT=8000
set "URL=http://localhost:%CASCADE_PORT%"

if not exist ".venv\Scripts\python.exe" (
  echo [setup needed] The Python environment .venv was not found. Run setup.bat once, then start.bat again.
  pause & exit /b 1
)
if not exist "web\dist\index.html" (
  where npm >nul 2>&1 || (echo [setup needed] The interface is not built and Node.js/npm was not found. Install Node.js 20+ and run setup.bat. & pause & exit /b 1)
  echo Building the interface ^(first run only^)...
  pushd web & call npm run build & popd
  if not exist "web\dist\index.html" (echo [error] Interface build failed; see the messages above. & pause & exit /b 1)
)

rem Settings from .env (KEY=VALUE lines, # for comments). Model backends stay off unless .env names one.
if exist ".env" for /f "usebackq eol=# tokens=1,* delims==" %%a in (".env") do set "%%a=%%b"
if not defined CASCADE_LLM set CASCADE_LLM=off

powershell -NoProfile -Command "try { Invoke-WebRequest -UseBasicParsing http://127.0.0.1:%CASCADE_PORT%/api/health -TimeoutSec 2 | Out-Null; exit 0 } catch { exit 1 }"
if not errorlevel 1 (
  echo Cascade Tribunal is already running at %URL%
  if not defined CASCADE_NO_BROWSER start "" "%URL%"
  exit /b 0
)
powershell -NoProfile -Command "if (Get-NetTCPConnection -LocalPort %CASCADE_PORT% -State Listen -ErrorAction SilentlyContinue) { exit 1 }"
if errorlevel 1 (
  echo [error] Port %CASCADE_PORT% is used by another program. Close it, or run: set CASCADE_PORT=8010 ^&^& start.bat
  pause & exit /b 1
)

echo Starting the server on %URL% ...
start "Cascade Tribunal server (close this window to stop)" /min ".venv\Scripts\python.exe" -m uvicorn cascade.api:app --host 127.0.0.1 --port %CASCADE_PORT%
powershell -NoProfile -Command "for ($i = 0; $i -lt 60; $i++) { try { Invoke-WebRequest -UseBasicParsing http://127.0.0.1:%CASCADE_PORT%/api/health -TimeoutSec 2 | Out-Null; exit 0 } catch { Start-Sleep -Milliseconds 500 } }; exit 1"
if errorlevel 1 (
  echo [error] The server did not answer within 30 seconds. Look at the minimised "Cascade Tribunal server" window for the error.
  pause & exit /b 1
)
echo Ready: %URL%   (stop with stop.bat, or close the server window)
if not defined CASCADE_NO_BROWSER start "" "%URL%"
exit /b 0
