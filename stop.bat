@echo off
rem Stops the Cascade Tribunal server started by start.bat. Only stops a Python process; anything else on the port is left alone.
setlocal
if not defined CASCADE_PORT set CASCADE_PORT=8000
powershell -NoProfile -Command "$ids = Get-NetTCPConnection -LocalPort %CASCADE_PORT% -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique; if (-not $ids) { 'Cascade Tribunal is not running on port %CASCADE_PORT%.'; exit 0 }; foreach ($id in $ids) { $p = Get-Process -Id $id; if ($p.ProcessName -notlike 'python*') { \"Port %CASCADE_PORT% belongs to $($p.ProcessName) (pid $id); not stopping it.\"; exit 1 }; Stop-Process -Id $id -Force; \"Stopped the server (pid $id).\" }"
