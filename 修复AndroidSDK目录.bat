@echo off
chcp 65001 >nul
title 修复 Android SDK 目录结构

echo ========================================
echo 🔧 修复 Android SDK 目录结构
echo ========================================
echo.

set SDK_PATH=C:\Android\Sdk

echo [1/3] 创建目录结构...
if not exist "%SDK_PATH%\cmdline-tools\latest\bin" (
    mkdir "%SDK_PATH%\cmdline-tools\latest\bin" 2>nul
    mkdir "%SDK_PATH%\cmdline-tools\latest\lib" 2>nul
    echo   ✅ latest 目录已创建
) else (
    echo   ✅ latest 目录已存在
)
echo.

echo [2/3] 复制文件到正确位置...
if exist "%SDK_PATH%\cmdline-tools\bin\sdkmanager.bat" (
    echo   发现 sdkmanager.bat，复制到 latest\bin\
    copy /Y "%SDK_PATH%\cmdline-tools\bin\*" "%SDK_PATH%\cmdline-tools\latest\bin\" >nul
    
    if exist "%SDK_PATH%\cmdline-tools\lib" (
        xcopy /E /I /Y "%SDK_PATH%\cmdline-tools\lib" "%SDK_PATH%\cmdline-tools\latest\lib" >nul
    )
    
    echo   ✅ 文件复制完成
) else if exist "%SDK_PATH%\cmdline-tools\latest\bin\sdkmanager.bat" (
    echo   ✅ sdkmanager 已在正确位置
) else (
    echo   ❌ 找不到 sdkmanager.bat
    echo.
    echo 💡 需要重新下载 Android SDK Command-line Tools
    echo.
    echo 下载地址: https://developer.android.com/studio#command-tools
    echo 解压到: %SDK_PATH%\cmdline-tools\latest
    echo.
    pause
    exit /b 1
)
echo.

echo [3/3] 创建必要的空目录...
mkdir "%SDK_PATH%\platforms" 2>nul
mkdir "%SDK_PATH%\build-tools" 2>nul
mkdir "%SDK_PATH%\platform-tools" 2>nul
echo   ✅ 目录创建完成
echo.

echo ========================================
echo ✅ Android SDK 目录结构已修复!
echo ========================================
echo.
echo 📂 当前结构:
echo   %SDK_PATH%\cmdline-tools\latest\bin\sdkmanager.bat
echo   %SDK_PATH%\platforms\
echo   %SDK_PATH%\build-tools\
echo   %SDK_PATH%\platform-tools\
echo.
echo 🚀 现在可以运行: 一键构建APK.bat
echo.

pause