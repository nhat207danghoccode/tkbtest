@echo off
chcp 65001 >nul
title Thoi khoa bieu - Cao dang Y te Ha Tinh
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
