@echo off
rem One-time installation. Downloads Python and Node packages (needs internet once); start.bat needs none afterwards.
setlocal
cd /d "%~dp0"
where py >nul 2>&1 && (set "PY=py -3") || (set "PY=python")
if not exist ".venv\Scripts\python.exe" (
  echo Creating the Python environment...
  %PY% -m venv .venv || (echo [error] Python 3.13 was not found. Install it from python.org and tick "Add to PATH". & pause & exit /b 1)
)
".venv\Scripts\python.exe" -m pip install -r requirements.txt || (echo [error] pip install failed. & pause & exit /b 1)
where npm >nul 2>&1 || (echo [error] Node.js/npm was not found. Install Node.js 20+ from nodejs.org. & pause & exit /b 1)
pushd web
call npm ci || (popd & echo [error] npm ci failed. & pause & exit /b 1)
call npm run build || (popd & echo [error] Interface build failed. & pause & exit /b 1)
popd
if not exist ".env" copy ".env.example" ".env" >nul
echo.
echo Setup complete. Double-click start.bat to run Cascade Tribunal.
pause
