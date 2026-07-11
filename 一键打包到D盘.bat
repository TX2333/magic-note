
@echo off
chcp 65001 >nul
cls

echo ========================================
echo 📦 Flutter魔法笔记 - 一键打包工具
echo ========================================
echo.

set "SOURCE_FLUTTER=C:\flutter"
set "SOURCE_PROJECT=D:\谜语人app"
set "TARGET=D:\Flutter魔法笔记"

echo 📂 目标位置: %TARGET%
echo.

if exist "%TARGET%" (
    echo ⚠️  目标文件夹已存在，是否继续？
    echo    继续会覆盖同名文件 (Y/N)
    set /p "choice="
    if /i not "%choice%"=="Y" (
        echo ❌ 已取消
        pause
        exit /b
    )
)

echo.
echo ========================================
echo 🚀 开始打包...
echo ========================================
echo.

:: 创建目录结构
echo [1/5] 📁 创建目录结构...
if not exist "%TARGET%" mkdir "%TARGET%"
if not exist "%TARGET%\flutter_sdk" mkdir "%TARGET%\flutter_sdk"
if not exist "%TARGET%\项目文件" mkdir "%TARGET%\项目文件"
if not exist "%TARGET%\工具" mkdir "%TARGET%\工具"
if not exist "%TARGET%\文档" mkdir "%TARGET%\文档"
echo ✅ 目录结构已创建
echo.

:: 复制项目文件
echo [2/5] 📋 复制项目文件...
xcopy "%SOURCE_PROJECT%\*" "%TARGET%\项目文件\" /E /I /Y /EXCLUDE:%~dp0exclude.txt >nul
echo ✅ 项目文件复制完成
echo.

:: 复制 Flutter SDK (跳过 .git 文件夹节省空间)
echo [3/5] 📦 复制 Flutter SDK (约 2.3GB，需要几分钟...)
echo     请耐心等待，不要关闭窗口...
xcopy "%SOURCE_FLUTTER%\*" "%TARGET%\flutter_sdk\" /E /I /Y /EXCLUDE:%~dp0exclude.txt >nul
echo ✅ Flutter SDK 复制完成
echo.

:: 创建环境配置脚本
echo [4/5] ⚙️  创建启动脚本...

(
echo @echo off
echo chcp 65001 ^>nul
echo cls
echo.
echo echo ========================================
echo echo ✨ 魔法笔记 - 一键配置环境
echo echo ========================================
echo echo.
echo.
echo set "FLUTTER_ROOT=%%~dp0flutter_sdk"
echo set "PATH=%%FLUTTER_ROOT%%\bin;%%PATH%%"
echo echo ✅ Flutter 环境已配置
echo echo    Flutter: %%FLUTTER_ROOT%%
echo echo.
echo cd /d "%%~dp0项目文件"
echo echo 📂 当前目录: %%cd%%
echo echo.
echo echo ========================================
echo echo 🚀 可用命令:
echo echo ========================================
echo echo   flutter doctor  - 检查环境
echo echo   flutter run     - 运行应用
echo echo   flutter build apk --release - 构建APK
echo echo.
echo cmd /k
) > "%TARGET%\工具\设置环境.bat"

(
echo @echo off
echo chcp 65001 ^>nul
echo cls
echo.
echo echo ========================================
echo echo 🌐 魔法笔记 - Web版启动器
echo echo ========================================
echo echo.
echo cd /d "%%~dp0..\项目文件"
echo echo 🚀 启动 Web 服务器...
echo echo.
echo echo 💡 启动后，浏览器访问: http://localhost:5000
echo echo    按 Ctrl+C 停止服务器
echo echo ========================================
echo.
echo python magic_note_web.py
echo.
echo pause
) > "%TARGET%\工具\启动Web版.bat"

echo ✅ 启动脚本已创建
echo.

:: 创建说明文档
echo [5/5] 📄 创建使用说明...
(
echo ========================================
echo ✨ 魔法笔记 - 使用说明
echo ========================================
echo.
echo 📦 文件夹说明:
echo.
echo   flutter_sdk\      - Flutter SDK (2.3GB)
echo   项目文件\         - 魔法笔记完整项目代码
echo   工具\             - 便捷脚本
echo   文档\             - 相关文档
echo.
echo ========================================
echo 🚀 快速开始
echo ========================================
echo.
echo 方式一: Web版 (推荐，无需配置)
echo ----------------------------------------
echo   1. 双击 工具\启动Web版.bat
echo   2. 浏览器访问: http://localhost:5000
echo   3. ✨ 开始你的魔法书写之旅!
echo.
echo 方式二: Flutter 构建 APK
echo ----------------------------------------
echo   1. 双击 工具\设置环境.bat
echo   2. 在打开的命令行中运行:
echo      flutter build apk --release
echo   3. APK 输出位置: build\app\outputs\flutter-apk\
echo.
echo ========================================
echo ✨ 魔法笔记功能
echo ========================================
echo.
echo   🖍️  无限画布，自由书写
echo   ✨ 发光笔迹，粒子特效
echo   🤖 AI 智能识别手写内容
echo   💬 温暖而有哲理的魔法回应
echo   🌙 深色魔法主题
echo.
echo ========================================
echo 💡 使用提示
echo ========================================
echo.
echo   - 写字时尽量工整，便于 AI 识别
echo   - 字写大一点，识别效果更好
echo   - 停笔 2 秒后会自动触发 AI
echo   - 只要继续写字，计时器就会重置
echo.
echo ========================================
echo 📝 其他说明
echo ========================================
echo.
echo   - 本文件夹是完全便携的，可以复制到任何电脑使用
echo   - 不需要安装任何东西（除了 Python 用于 Web版）
echo   - 所有配置都是相对路径，不修改系统环境
echo.
echo ========================================
echo 祝您使用愉快! ✨🌙
echo ========================================
) > "%TARGET%\文档\使用说明.txt"

echo ✅ 说明文档已创建
echo.

echo ========================================
echo ✅ 打包完成!
echo ========================================
echo.
echo 📂 位置: %TARGET%
echo.

:: 计算大小
for /f "delims=" %%a in ('dir /s /a "%TARGET%" ^| find "个字节"') do set size=%%a
for /f "tokens=3" %%a in ("%size%") do set total=%%a

echo 📦 总大小: %total% 字节
echo.

echo ========================================
echo 📋 内容清单:
echo ========================================
echo.
dir /b "%TARGET%"
echo.
echo ========================================
echo 💡 下一步:
echo ========================================
echo.
echo   1. 复制整个 "Flutter魔法笔记" 文件夹到 U盘/其他电脑
echo   2. 双击 工具\启动Web版.bat 立即体验
echo   3. 或者运行 工具\设置环境.bat 构建APK
echo.
echo 🎉 祝您使用愉快!
echo.

pause
start "" "%TARGET%"
