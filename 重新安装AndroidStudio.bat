@echo off
chcp 65001 >nul
title 魔法笔记 - 重新安装 Android Studio

echo ========================================
echo 🔄 重新启动 Android Studio 安装
echo ========================================
echo.

echo 正在查找安装包...
echo.

set "INSTALL_EXE=C:\Users\Windows\AppData\Local\Temp\chocolatey\AndroidStudio\2025.2.3\android-studio-2025.2.3.9-windows.exe"

if exist "%INSTALL_EXE%" (
    echo ✅ 找到安装包!
    echo.
    echo 正在以管理员身份启动安装程序...
    echo.
    
    powershell -Command "Start-Process '%INSTALL_EXE%' -Verb RunAs"
    
    echo.
    echo ========================================
    echo 📋 安装建议:
    echo ========================================
    echo.
    echo 1. 选择 "Standard" 标准安装模式
    echo 2. 接受所有默认选项
    echo 3. 等待 SDK 下载完成（约 5-10 分钟）
    echo.
    echo ========================================
    echo 💡 如果再次崩溃:
    echo ========================================
    echo.
    echo 方案 A: 手动下载安装包
    echo   https://developer.android.com/studio
    echo.
    echo 方案 B: 立即使用 Web 版（推荐！）
    echo   双击 启动Web版.bat
    echo   功能完全一样，现在就能用！
    echo.
    
) else (
    echo ❌ 未找到安装包
    echo.
    echo 💡 请手动下载:
    echo   https://developer.android.com/studio
    echo.
    echo 或者先使用 Web 版:
    echo   双击 启动Web版.bat
    echo.
)

pause