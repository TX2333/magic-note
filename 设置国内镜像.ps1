# 设置 Flutter 国内镜像源（清华大学）
$env:FLUTTER_STORAGE_BASE_URL = "https://mirrors.tuna.tsinghua.edu.cn/flutter"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"

# 永久设置到用户环境变量
[Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://mirrors.tuna.tsinghua.edu.cn/flutter", "User")
[Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://pub.flutter-io.cn", "User")

Write-Host "✅ Flutter 镜像源已设置"
Write-Host ""
Write-Host "FLUTTER_STORAGE_BASE_URL = https://mirrors.tuna.tsinghua.edu.cn/flutter"
Write-Host "PUB_HOSTED_URL            = https://pub.flutter-io.cn"
Write-Host ""
Write-Host "💡 重启终端后生效"
