@echo off
title CheerUp! Installer

echo.
echo  CheerUp! for Cascadeur - Installer
echo  ====================================
echo.
echo  Launching installer with administrator privileges...
echo  Please click "Yes" on the UAC prompt.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0install.ps1""' -Verb RunAs -Wait"

if %errorlevel% neq 0 (
    echo.
    echo  Administrator access was cancelled. Installation aborted.
    echo.
    pause
)
