@echo off
setlocal
title Envoi des fiches vers GitHub
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Envoi-Fiches-GitHub.ps1"
if errorlevel 1 (
  echo.
  echo Impossible de lancer l'outil. Appuyez sur une touche pour fermer.
  pause >nul
)
endlocal
