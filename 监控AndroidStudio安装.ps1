# 持续监控 Android Studio 安装状态
$timeout = 3600  # 最多等待1小时
$elapsed = 0
$checkInterval = 30  # 每30秒检查一次

Write-Host "========================================"
Write-Host "🔍 开始监控 Android Studio 安装状态"
Write-Host "⏱️  每 $checkInterval 秒检查一次，最多等待 $($timeout/60) 分钟"
Write-Host "========================================"
Write-Host ""

$paths = @(
    "C:\Program Files\Android\Android Studio",
    "C:\Program Files (x86)\Android\Android Studio",
    "$env:LOCALAPPDATA\Android\Android Studio"
)

while ($elapsed -lt $timeout) {
    $installed = $false
    $installedPath = $null
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            $installed = $true
            $installedPath = $path
            break
        }
    }
    
    $time = Get-Date -Format "HH:mm:ss"
    
    if ($installed) {
        Write-Host ""
        Write-Host "✅ [$time] Android Studio 安装完成！"
        Write-Host "📂 安装位置: $installedPath"
        Write-Host ""
        Write-Host "🎯 下一步操作:"
        Write-Host "   1. 启动 Android Studio"
        Write-Host "   2. 完成 SDK 安装向导"
        Write-Host "   3. 在 SDK Manager 中安装命令行工具"
        Write-Host "   4. 运行 '启动Flutter版.bat' 构建 APK"
        Write-Host ""
        break
    } else {
        Write-Host "⏳ [$time] 仍在安装中... 已等待 $elapsed 秒"
    }
    
    Start-Sleep -Seconds $checkInterval
    $elapsed += $checkInterval
}

if (-not $installed) {
    Write-Host ""
    Write-Host "⚠️  等待超时，安装可能卡住了"
    Write-Host "💡 建议手动检查安装状态，或重新运行安装程序"
}

Write-Host ""
Read-Host "按 Enter 退出"
