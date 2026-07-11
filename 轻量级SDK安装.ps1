# 轻量级 Android SDK 安装脚本
# 仅安装构建 APK 所需的命令行工具

Write-Host "========================================"
Write-Host "✨ 轻量级 Android SDK 安装"
Write-Host "========================================"
Write-Host ""

# 创建 SDK 目录
$sdkPath = "C:\Android\Sdk"
if (-not (Test-Path $sdkPath)) {
    New-Item -ItemType Directory -Path $sdkPath -Force | Out-Null
    Write-Host "✅ 创建 SDK 目录: $sdkPath"
}

Write-Host ""
Write-Host "📋 安装步骤:"
Write-Host "   1. 下载 Android SDK Command-line Tools"
Write-Host "   2. 解压到 $sdkPath\cmdline-tools"
Write-Host "   3. 使用 sdkmanager 安装构建工具"
Write-Host ""
Write-Host "📦 总下载大小: ~150 MB"
Write-Host ""

# 设置环境变量
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkPath, "User")

$envPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($envPath -notlike "*$sdkPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$sdkPath\cmdline-tools\latest\bin;$sdkPath\platform-tools", "User")
}

Write-Host "✅ 环境变量已配置"
Write-Host ""
Write-Host "========================================"
Write-Host "💡 下一步操作:"
Write-Host "   1. 浏览器打开："
Write-Host "      https://developer.android.com/studio#command-tools"
Write-Host "   2. 下载 Command-line Tools for Windows"
Write-Host "   3. 解压到 $sdkPath\cmdline-tools\latest"
Write-Host "   4. 运行: sdkmanager --install 'platforms;android-34' 'build-tools;34.0.0' 'platform-tools'"
Write-Host ""
Write-Host "⏱️  预计 5-10 分钟完成"
Write-Host "========================================"
Write-Host ""
Write-Host "❓ 或者，你想继续尝试安装 Android Studio 吗？"
Write-Host ""
Read-Host "按 Enter 退出"
