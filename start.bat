@echo off
echo gm_admin:admin123 > "%APPDATA%\Main\Local Store\user_config.txt"
start "" "%~dp0main.exe"
