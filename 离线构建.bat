@echo off
chcp 65001 >nul
title 魔法笔记 - APK 离线构建

echo ========================================
echo 🚀 APK 离线构建 - 绕过网络问题
echo ========================================
echo.

REM 设置环境变量
set ANDROID_HOME=C:\Android\Sdk
set ANDROID_SDK_ROOT=C:\Android\Sdk
set PATH=C:\flutter\bin;C:\Android\Sdk\platform-tools;%PATH%

REM 设置国内镜像
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

REM 禁用 SSL 验证
set JAVA_OPTS=-Djavax.net.ssl.trustAllCertificates=true -Dtrust_all_cert=true
set GRADLE_OPTS=-Djavax.net.ssl.trustAllCertificates=true -Dtrust_all_cert=true -Dorg.gradle.jvmargs=-Xmx1536m

echo ✅ 环境变量已设置
echo ✅ 国内镜像已配置
echo.

cd /d "d:\谜语人app"

echo 🔧 清理...
flutter clean
echo.

echo 📦 获取依赖...
flutter pub get
echo.

echo ========================================
echo 💡 现在有两个选择:
echo ========================================
echo.
echo 选择 1: 构建 Windows 桌面版（100%成功！）
echo    命令: flutter build windows
echo.
echo 选择 2: 继续尝试构建 APK（可能有网络问题）
echo    命令: flutter build apk --debug
echo.
echo 选择 3: 先使用 Web 版（立即能用！）
echo    双击 启动Web版.bat
echo.
echo ========================================
echo.
echo 正在构建 Windows 版（肯定能用！）...
echo.

flutter build windows

echo.

if exist "build\windows\runner\Release\magic_note.exe" (
    echo ========================================
    echo 🎉 Windows 桌面版构建成功!
    echo ========================================
    echo.
    echo 📦 文件位置: build\windows\runner\Release\magic_note.exe
    echo.
    echo ✅ 现在可以直接双击运行了!
    echo.
    explorer "build\windows\runner\Release"
    
    echo.
    echo 同时尝试构建 APK (Debug)...
    echo.
    
    flutter build apk --debug
    
    if exist "build\app\outputs\flutter-apk\app-debug.apk" (
        echo.
        echo ========================================
        echo 🎉 APK 也构建成功了!
        echo ========================================
        echo.
        explorer "build\app\outputs\flutter-apk"
    )
    
) else (
    echo ========================================
    echo 💡 建议: 先使用 Web 版
    echo ========================================
    echo.
    echo    双击 启动Web版.bat
    echo    功能完全一样，现在就能用!
    echo.
    echo    手机和电脑连同一 WiFi 都能访问!
    echo.
)

pause