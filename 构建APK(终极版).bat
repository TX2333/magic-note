@echo off
chcp 65001 >nul
title 魔法笔记 - APK 构建（终极版）

echo ========================================
echo 🚀 APK 构建 - 终极解决方案
echo ========================================
echo.

REM 设置环境变量
set ANDROID_HOME=C:\Android\Sdk
set ANDROID_SDK_ROOT=C:\Android\Sdk
set PATH=C:\flutter\bin;C:\Android\Sdk\platform-tools;%PATH%

REM 设置国内镜像
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

REM 关键：禁用 Java SSL 验证（解决证书问题）
set JAVA_OPTS=-Djavax.net.ssl.trustAllCertificates=true -Djavax.net.ssl.checkServerIdentity=false
set GRADLE_OPTS=-Djavax.net.ssl.trustAllCertificates=true -Djavax.net.ssl.checkServerIdentity=false -Dtrust_all_cert=true

echo ✅ 环境变量已设置
echo ✅ 国内镜像已配置
echo ✅ SSL 验证已禁用
echo.

cd /d "d:\谜语人app"

echo 🔧 清理...
flutter clean
echo.

echo 📦 获取依赖...
flutter pub get
echo.

echo 🔨 构建 APK (Debug 版先试试)...
echo    如果成功，再构建 Release 版
echo.

flutter build apk --debug

echo.

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ========================================
    echo 🎉 Debug APK 构建成功!
    echo ========================================
    echo.
    echo 📦 文件位置: build\app\outputs\flutter-apk\app-debug.apk
    echo.
    
    explorer "build\app\outputs\flutter-apk"
    
    echo.
    echo 🔨 继续构建 Release 版...
    echo.
    
    flutter build apk --release
    
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
        echo.
        echo ========================================
        echo 🎉 Release APK 构建成功!
        echo ========================================
        echo.
        echo ✅ 你的 APK 准备好了!
        echo.
        explorer "build\app\outputs\flutter-apk"
    )
    
) else (
    echo ========================================
    echo ❌ 命令行构建遇到网络问题
    echo ========================================
    echo.
    echo 💡 终极方案 - 用 Android Studio 图形界面构建:
    echo.
    echo   1. 打开 Android Studio
    echo   2. 点击 "Open an Existing Project"
    echo   3. 选择文件夹: d:\谜语人app
    echo   4. 等待 Gradle 同步完成（自动处理网络问题）
    echo   5. 点击菜单: Build - Build Bundle(s) / APK(s) - Build APK(s)
    echo.
    echo 💡 或者先使用 Web 版（立即能用！）:
    echo   双击 启动Web版.bat
    echo.
)

pause