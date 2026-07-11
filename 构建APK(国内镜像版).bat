@echo off
chcp 65001 >nul
title 魔法笔记 - APK 构建（国内镜像版）

echo ========================================
echo 🚀 构建 APK - 使用国内镜像
echo ========================================
echo.

REM 设置环境变量
set ANDROID_HOME=C:\Android\Sdk
set ANDROID_SDK_ROOT=C:\Android\Sdk
set PATH=C:\flutter\bin;C:\Android\Sdk\platform-tools;%PATH%

REM 设置 Flutter 国内镜像
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

echo ✅ 环境变量已设置
echo ✅ 国内镜像已配置
echo.

REM 进入项目目录
cd /d "d:\谜语人app"

echo 🔧 清理旧的构建...
flutter clean
echo.

echo 📦 重新获取依赖...
flutter pub get
echo.

echo 🔨 开始构建 Release APK...
echo    这需要 2-5 分钟，请耐心等待...
echo.

flutter build apk --release

echo.

REM 检查结果
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ========================================
    echo 🎉 APK 构建成功!
    echo ========================================
    echo.
    echo 📦 文件位置: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo ✅ 现在可以将 APK 复制到手机安装使用了!
    echo.
    
    REM 打开文件夹
    explorer "build\app\outputs\flutter-apk"
    
) else (
    echo ========================================
    echo ❌ 构建失败
    echo ========================================
    echo.
    echo 💡 备选方案 - 使用 Web 版（立即能用！）
    echo.
    echo    双击 启动Web版.bat
    echo    功能完全一样，手机电脑都能用!
    echo.
)

pause