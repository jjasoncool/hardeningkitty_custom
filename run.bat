@echo off
chcp 65001
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0EGST\main.ps1"
if %errorlevel% neq 0 pause
