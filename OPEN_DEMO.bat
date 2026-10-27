@echo off
cd /d "%~dp0"
py -3 --version >nul 2>&1
if not errorlevel 1 (
  py -3 tools\preview_server.py
) else (
  python tools\preview_server.py
)
pause
