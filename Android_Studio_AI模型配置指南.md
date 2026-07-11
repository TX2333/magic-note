
# Android Studio AI 模型配置完整指南

## 📋 目录
- [方案 1：项目内 AI 模型配置界面](#方案-1项目内-ai-模型配置界面)
- [方案 2：Android Studio Studio Bot 配置](#方案-2android-studio-studio-bot-内置-ai-助手)
- [常用模型 API 配置参考](#常用模型-api-配置参考)

---

## 🎯 方案 1：项目内 AI 模型配置界面

### ✨ 功能特点
- ✅ 可视化配置界面，在 APP 内直接操作
- ✅ 支持所有 OpenAI 兼容的 API
- ✅ 预设常用模型，一键添加
- ✅ 配置保存在本地，安全可靠
- ✅ 实时切换模型，无需重启
- ✅ 支持编辑/删除模型

### 📱 使用步骤

#### 1. 打开配置界面
在 APP 中导航到：**设置 → AI 模型配置**

#### 2. 添加自定义模型
点击右上角 **+** 按钮，填写以下信息：

| 字段 | 说明 | 示例 |
|------|------|------|
| **模型显示名称** | 给模型起个名字，方便识别 | 我的 GPT-4o |
| **服务商** | API 提供商标识 | OpenAI |
| **API 地址** | Base URL，以 `/v1` 结尾 | https://api.openai.com/v1 |
| **API Key** | 你的 API 密钥 | sk-... |
| **模型名称** | 具体的模型名 | gpt-4o-mini |

点击 **添加** 完成。

#### 3. 快速添加预设模型
在界面底部的 **"快速添加预设模型"** 区域，点击按钮即可快速填入常用配置，然后只需修改 API Key 即可。

#### 4. 切换当前模型
在 **已配置的模型** 列表中，点击单选按钮即可切换当前使用的模型。

#### 5. 编辑/删除模型
每个模型右侧有操作按钮：
- ✏️ 编辑：修改模型配置
- 📋 复制：复制 API Key 到剪贴板
- 🗑️ 删除：删除该模型（至少保留一个）

---

## 🤖 方案 2：Android Studio Studio Bot（内置 AI 助手）

### 📌 什么是 Studio Bot？
Studio Bot 是 Google 官方推出的 Android Studio 内置 AI 助手，基于 Gemini 模型，可以帮你：
- 写代码
- 解释代码
- 调试建议
- 学习 Android 开发

### ⚙️ 启用 Studio Bot

#### 前置条件
- ✅ Android Studio Hedgehog (2023.1.1) 或更高版本
- ✅ 登录 Google 账号
- ✅ 所在地区支持（目前支持 180+ 国家/地区）

#### 启用步骤

1. **打开 Android Studio 设置**
   ```
   File → Settings (Windows/Linux)
   Android Studio → Settings (Mac)
   ```

2. **找到 Studio Bot 配置**
   ```
   Languages & Frameworks → Studio Bot
   ```

3. **启用并登录**
   - ✅ 勾选 "Enable Studio Bot"
   - 点击 "Log in to Google"
   - 使用你的 Google 账号登录

4. **配置模型（如果支持自定义）**

   注意：目前 Studio Bot 默认使用 Google Gemini，暂不支持自定义模型。

---

## 📚 常用模型 API 配置参考

### 1. OpenAI 官方
```
显示名称：GPT-4o (OpenAI)
服务商：OpenAI
API 地址：https://api.openai.com/v1
API Key：sk-... (你的 OpenAI Key)
模型名称：gpt-4o-mini 或 gpt-4o
```

### 2. 智谱 AI（GLM）
```
显示名称：GLM-4-Flash (智谱)
服务商：GLM
API 地址：https://open.bigmodel.cn/api/paas/v4
API Key：9f9a... (已预设)
模型名称：glm-4-flash
```

### 3. 月之暗面（Moonshot）
```
显示名称：Moonshot-v1-32k (月之暗面)
服务商：Moonshot
API 地址：https://api.moonshot.cn/v1
API Key：sk-... (已预设)
模型名称：moonshot-v1-32k
```

### 4. 通义千问（阿里云）
```
显示名称：Qwen-Plus (通义千问)
服务商：Qwen
API 地址：https://dashscope.aliyuncs.com/compatible-mode/v1
API Key：sk-... (你的 Dashscope API Key)
模型名称：qwen-plus
```

### 5. 豆包（字节火山引擎）
```
显示名称：Doubao-Pro (豆包)
服务商：Doubao
API 地址：https://ark.cn-beijing.volces.com/api/v3
API Key：... (你的火山引擎 API Key)
模型名称：ep-20240805184157-xxxxx
```

### 6. DeepSeek（深度求索）
```
显示名称：DeepSeek-Chat (深度求索)
服务商：DeepSeek
API 地址：https://api.deepseek.com/v1
API Key：sk-...
模型名称：deepseek-chat
```

### 7. 零一万物（Yi）
```
显示名称：Yi-Large (零一万物)
服务商：Yi
API 地址：https://api.lingyiwanwu.com/v1
API Key：sk-...
模型名称：yi-large
```

---

## 🔒 安全提示

1. **API Key 安全**
   - API Key 仅保存在本地设备上
   - 不要将 API Key 提交到代码仓库
   - 定期轮换 API Key

2. **网络环境**
   - 部分 API 可能需要特定网络环境才能访问
   - 建议使用国内服务商以获得更好的速度

3. **费用提醒**
   - 大多数 AI API 按 token 计费
   - 建议在控制台设置用量提醒和预算

---

## 💡 使用技巧

### 1. 测试连接
添加模型后，可以使用 `AIService().testConnection(model)` 方法测试 API 是否正常工作。

### 2. 快速切换
在配置界面点击单选按钮即可实时切换，当前使用的模型会高亮显示绿色标记。

### 3. 备份配置
配置保存在 APP 的 SharedPreferences 中，可以通过导出数据功能备份你的模型配置。

---

## 🐛 常见问题

### Q: API 调用失败怎么办？
A: 检查以下几点：
- API Key 是否正确
- API 地址是否正确（确保以 `/v1` 结尾）
- 模型名称是否正确
- 网络是否正常，是否需要代理

### Q: 可以同时配置多个模型吗？
A: 可以！你可以添加任意多个模型，随时切换使用。

### Q: 配置会丢失吗？
A: 不会。配置保存在本地，只要不卸载 APP 就会一直保留。

### Q: Studio Bot 和项目内 AI 有什么区别？
A:
- **Studio Bot**：Google 官方的开发助手，帮助写 Android 代码，基于 Gemini
- **项目内 AI**：你的 APP 的功能，用于生成谜语和对话，可自定义任何 OpenAI 兼容模型

---

## 📞 获取帮助

如有问题或建议，欢迎反馈！

---

*最后更新：2024 年*
