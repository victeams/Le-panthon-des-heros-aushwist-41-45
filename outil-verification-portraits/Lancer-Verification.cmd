@echo off
setlocal
title Verification des portraits du Pantheon
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Verifier-Portraits-Pantheon.ps1"
if errorlevel 1 (
  echo.
  echo Impossible de lancer l'outil. Appuyez sur une touche pour fermer.
  pause >nul
)
endlocal
