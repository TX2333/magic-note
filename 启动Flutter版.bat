@echo off
chcp 65001 >nul
title ✨ 魔法笔记 - Flutter版
color 0D

echo.
echo ╔═════════════════════════════════════════════════╗
echo ║                                                   ║
echo ║              ✨ 魔法笔记 - Flutter版 ✨             ║
echo ║                                                   ║
echo ╚═════════════════════════════════════════════════╝
echo.

REM 设置Flutter路径
set PATH=C:\tools\flutter\bin;%PATH%

REM 检查Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter 未找到
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter SDK 已就绪
echo.

:menu
echo.
echo ┌─────────────────────────────────────────────┐
echo │               📱 操作菜单                      │
echo ├─────────────────────────────────────────────┤
echo │  1. 🔍 检查环境状态 (flutter doctor)         │
echo │  2. 📦 安装/更新依赖                         │
echo │  3. 🚀 构建 APK 安装包 (Release)             │
echo │  4. 📋 列出已连接设备                         │
echo │  5. 📱 直接运行到连接的手机                   │
echo │  6. 📖 打开构建指南                           │
echo │  0. ❌ 退出                                   │
echo └─────────────────────────────────────────────┘
echo.

set /p choice="请选择操作 [0-6]: "

if "%choice%"=="1" (
    echo.
    echo 🔍 检查 Flutter 环境...
    flutter doctor
    pause
    goto menu
)

if "%choice%"=="2" (
    echo.
    echo 📦 安装依赖...
    flutter pub get
    echo.
    echo ✅ 依赖安装完成
    pause
    goto menu
)

if "%choice%"=="3" (
    echo.
    echo 🚀 开始构建 APK...
    echo.
    flutter build apk --release
    echo.
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
        echo ✅ APK 构建成功！
        echo.
        echo 📂 APK 位置: build\app\outputs\flutter-apk\app-release.apk
        echo.
        echo 💡 将 app-release.apk 传到手机即可安装
    ) else (
        echo ❌ 构建失败，请检查错误信息
    )
    pause
    goto menu
)

if "%choice%"=="4" (
    echo.
    echo 📋 已连接设备列表:
    flutter devices
    pause
    goto menu
)

if "%choice%"=="5" (
    echo.
    echo 📱 运行到手机...
    flutter run
    pause
    goto menu
)

if "%choice%"=="6" (
    echo.
    echo 📖 打开构建指南...
    start APK构建指南.md
    pause
    goto menu
)

if "%choice%"=="0" (
    echo.
    echo 👋 再见！
    timeout /t 1 >nul
    exit /b 0
)

echo.
echo ❌ 无效选项，请重新选择
pause
goto menu
