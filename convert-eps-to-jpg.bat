@echo off
if "%~1"=="" (
    echo Usage: convert-eps-to-jpg.bat ^<parent-folder^>
    echo Example: convert-eps-to-jpg.bat graphics
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File "%~dp0convert-eps-to-jpg.ps1" -ParentFolder "%~1"
