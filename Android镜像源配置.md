# Android SDK 国内镜像源配置

## 🌐 可用的国内镜像源

### 1. 腾讯云镜像（推荐）
```
mirrors.cloud.tencent.com
```

### 2. 阿里云镜像
```
mirrors.aliyun.com
```

### 3. 大连东软信息学院
```
mirrors.neusoft.edu.cn
```

---

## 🔧 配置方法

### 方法一：在 Android Studio 中配置

1. 打开 Android Studio
2. 打开 **Settings** → **Appearance & Behavior** → **System Settings** → **Android SDK**
3. 点击 **SDK Update Sites** 标签
4. 点击 `+` 添加以下镜像：
   - 名称: `腾讯云镜像`
   - URL: `https://mirrors.cloud.tencent.com/android/repository/addon-6.xml`
5. 勾选 "Force https://... sources to be fetched using http://..."
6. 点击 Apply 保存

### 方法二：修改 hosts 文件（最有效）

以管理员身份打开 PowerShell，执行：
```powershell
# 备份 hosts 文件
Copy-Item C:\Windows\System32\drivers\etc\hosts C:\Windows\System32\drivers\etc\hosts.backup

# 添加镜像映射
Add-Content C:\Windows\System32\drivers\etc\hosts "`n# Android SDK 镜像`n203.208.41.32 dl.google.com`n203.208.41.32 dl-ssl.google.com"

Write-Host "✅ hosts 文件已修改"
Write-Host "💡 重启电脑生效"
```

### 方法三：使用 Android SDK 代理

在 Android Studio 的 SDK Manager 中：
1. 点击 **Tools** → **SDK Manager**
2. 点击 **Appearance & Behavior** → **System Settings** → **HTTP Proxy**
3. 选择 "Manual proxy configuration"
4. 设置 HTTP Proxy：
   - Host name: `mirrors.cloud.tencent.com`
   - Port number: `80`

---

## 🚀 Flutter 镜像源（已配置）

| 环境变量 | 值 |
|---------|-----|
| FLUTTER_STORAGE_BASE_URL | `https://mirrors.tuna.tsinghua.edu.cn/flutter` |
| PUB_HOSTED_URL | `https://pub.flutter-io.cn` |

---

## 💡 加速下载小技巧

1. **先运行镜像设置脚本**：`设置国内镜像.ps1`
2. **重启 Android Studio** 后再下载 SDK
3. 选择夜间下载，网络更稳定
4. 如果一个镜像慢，尝试另一个

---

## 📝 可用的镜像源列表

### Flutter 相关：
- 清华大学: `https://mirrors.tuna.tsinghua.edu.cn/flutter`
- 上海交大: `https://mirrors.sjtug.sjtu.edu.cn`
- 腾讯云: `https://mirrors.cloud.tencent.com/flutter`

### Android SDK 相关：
- 腾讯云: `mirrors.cloud.tencent.com`
- 阿里云: `mirrors.aliyun.com`
- 东软: `mirrors.neusoft.edu.cn`

---

*配置好镜像后，下载速度可以提升 5-10 倍！🚀*
