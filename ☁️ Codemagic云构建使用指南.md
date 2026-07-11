# ☁️ Codemagic 云构建使用指南

## 📋 概述

Codemagic 是一个专门为 Flutter 设计的云构建平台，构建成功率 100%。

## 🔧 准备工作

### 1. 项目已就绪

✅ 你的项目代码已推送到 GitHub:
- **仓库地址**: https://github.com/TX2333/magic-note
- **分支**: main
- **配置文件**: codemagic.yaml (已包含在项目中)

## 🚀 开始构建

### 步骤 1: 访问 Codemagic

打开浏览器访问: **https://codemagic.io/**

### 步骤 2: 注册/登录

1. 点击右上角的 "Sign up" 或 "Log in"
2. 选择 "Sign up with GitHub"
3. 使用你的 GitHub 账号授权登录

### 步骤 3: 添加应用

1. 登录后点击 "Add application"
2. 选择 "GitHub" 作为 Git 提供商
3. 找到并选择 `magic-note` 仓库
4. 点击 "Next: Select project type"

### 步骤 4: 配置构建

1. Codemagic 会自动检测到项目中的 `codemagic.yaml` 配置文件
2. 选择 workflow: `flutter-android-apk`
3. 点击 "Start new build"

### 步骤 5: 等待构建完成

- 构建过程大约需要 **5-10 分钟**
- 你可以实时查看构建日志
- 构建成功后会自动生成 APK 文件

### 步骤 6: 下载 APK

1. 构建完成后，点击 "Artifacts" 标签
2. 找到 `app-release.apk` 文件
3. 点击下载按钮保存到电脑

## 📲 安装到手机

### 方法一: 直接传输

1. 将下载的 APK 文件通过 QQ/微信传到手机
2. 在手机上点击文件进行安装
3. 允许"未知来源"应用安装

### 方法二: 使用 ADB

```bash
# 手机连接电脑，开启 USB 调试
adb install app-release.apk
```

## ⚙️ GitHub Actions 备选方案

除了 Codemagic，你的项目还配置了 GitHub Actions:

1. 访问: https://github.com/TX2333/magic-note/actions
2. 点击左侧的 "🔨 构建 APK"
3. 点击 "Run workflow" → 选择 main 分支 → 点击 "Run workflow"
4. 等待构建完成（约 5-10 分钟）
5. 在构建详情页面的 "Artifacts" 部分下载 APK

## 📝 常见问题

### Q: 构建失败怎么办？

A: 检查构建日志中的具体错误信息。常见问题：
- 依赖包版本冲突
- Android SDK 配置问题
- 代码语法错误

### Q: 可以自定义构建配置吗？

A: 可以，修改 `codemagic.yaml` 文件即可。支持自定义构建步骤、环境变量等。

### Q: Codemagic 收费吗？

A: 免费额度：每月 500 分钟构建时间，对于个人项目完全够用。

### Q: 如何收到构建完成通知？

A: Codemagic 支持邮件、Slack 等多种通知方式，可在设置中配置。

## 🎯 为什么选择 Codemagic？

| 特性 | Codemagic | Gitee Go | GitHub Actions |
|------|-----------|----------|----------------|
| Flutter 专用 | ✅ 是 | ❌ 否 | ⚠️ 需手动配置 |
| 构建速度 | ⚡ 快 | 🐢 慢 | ⚡ 快 |
| 成功率 | 💯 100% | ⚠️ 不稳定 | ✅ 高 |
| 配置复杂度 | 🟢 简单 | 🔴 复杂 | 🟡 中等 |
| 免费额度 | 500分钟/月 | 有限 | 2000分钟/月 |

## 📞 技术支持

如有问题，可以:
1. 查看 Codemagic 官方文档: https://docs.codemagic.io/
2. 在 GitHub 提交 Issue

---

**最后更新**: 2026-07-10
