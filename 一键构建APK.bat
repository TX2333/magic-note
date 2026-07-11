@echo off
chcp 65001 >nul
title 魔法笔记 - APK 一键构建

echo ========================================
echo 🚀 魔法笔记 - APK 一键构建
echo ========================================
echo.

REM 设置环境变量
set ANDROID_HOME=C:\Android\Sdk
set ANDROID_SDK_ROOT=C:\Android\Sdk
set JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot
set PATH=C:\flutter\bin;C:\Android\Sdk\platform-tools;C:\Android\Sdk\cmdline-tools\bin;%JAVA_HOME%\bin;%PATH%

echo [1/4] 检查环境...
flutter --version
echo.
echo ✅ Flutter 环境就绪
echo.

echo [2/4] 接受 Android SDK 许可证
echo    请一路按 y 接受所有许可证
echo.
flutter doctor --android-licenses
echo.
echo ✅ 许可证已接受
echo.

echo [3/4] 检查 Flutter 状态...
flutter doctor
echo.

echo [4/4] 开始构建 Release APK
echo    这需要 2-5 分钟，请耐心等待...
echo.
flutter build apk --release
echo.

REM 检查结果
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ========================================
    echo ✅ APK 构建成功!
    echo ========================================
    echo.
    echo 📦 文件: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 🎉 现在可以将 APK 复制到手机安装使用了!
    echo.
) else (
    echo ❌ 构建失败，请查看上面的错误信息
    echo.
)

pause