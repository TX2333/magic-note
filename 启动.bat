@echo off
chcp 65001 >nul
title ✨ 魔法笔记 - Magic Note 启动器
color 0D

echo.
echo ╔═════════════════════════════════════════════════╗
echo ║                                                 ║
echo ║        ✨ 魔法笔记 - Magic Note ✨               ║
echo ║                                                 ║
echo ║      写字即有回应，一本有灵性的笔记。              ║
echo ║                                                 ║
echo ╚═════════════════════════════════════════════════╝
echo.

REM 检查Python是否安装
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python未安装，请先安装Python 3.x
    pause
    exit /b 1
)
echo ✅ Python已安装

echo.
REM 检查Flutter是否安装
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Flutter未安装，请先安装Flutter SDK
    echo 🔗 下载地址: https://flutter.dev/docs/get-started/install
    pause
) else (
    echo ✅ Flutter已安装
)

echo.
echo 📦 检查魔法素材...
flutter pub get
if %errorlevel% neq 0 (
    echo ⚠️  魔法素材可能有问题，继续执行...
) else (
    echo ✅ 魔法素材准备完毕
)

:menu
echo.
echo ┌─────────────────────────────────────────────┐
echo │            ✨ 魔法菜单                        │
echo ├─────────────────────────────────────────────┤
echo │  1. 🚀 启动魔法笔记 (Debug)                  │
echo │  2. 🚀 启动魔法笔记 (Release)                │
echo │  3. 📱 查看可用设备                           │
echo │  4. � 编织APK安装包 (Release)               │
echo │  5. � 编织APK安装包 (Debug)                 │
echo │  6. 🤖 查看魔法源泉 (AI配置)                  │
echo │  0. ❌ 退出                                  │
echo └─────────────────────────────────────────────┘
echo.

set /p choice="请选择咒文 [0-6]: "

if "%choice%"=="1" (
    echo.
    echo 🚀 启动魔法笔记...
    echo ✨ 愿古老的智慧与你同在
    python launcher.py --no-dep-check
    goto menu
)

if "%choice%"=="2" (
    echo.
    echo 🚀 启动魔法笔记 (Release)...
    echo ✨ 愿古老的智慧与你同在
    python launcher.py --no-dep-check --release
    goto menu
)

if "%choice%"=="3" (
    echo.
    echo 📱 可用设备列表:
    python launcher.py --devices
    pause
    goto menu
)

if "%choice%"=="4" (
    echo.
    echo � 正在编织魔法APK (Release)...
    python launcher.py --no-dep-check --build --release
    pause
    goto menu
)

if "%choice%"=="5" (
    echo.
    echo � 正在编织魔法APK (Debug)...
    python launcher.py --no-dep-check --build --no-release
    pause
    goto menu
)

if "%choice%"=="6" (
    echo.
    python launcher.py --config
    pause
    goto menu
)

if "%choice%"=="0" (
    echo.
    echo 🌙 魔法已封存，下次再见...
    timeout /t 1 >nul
    exit /b 0
)

echo.
echo ❌ 无效的咒文，请重新选择
pause
goto menu
