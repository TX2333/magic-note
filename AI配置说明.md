# AI API 配置说明

## 内置AI模型

本应用内置了两个大语言模型API，用于增强谜语体验：

### 1. GLM-4-Flash (智谱AI)
- **API Base**: `https://open.bigmodel.cn/api/paas/v4`
- **API Key**: `9f9a917e3cbf480291bfe80b2d8ed744.8RW6t1WfbnNJz7Oo`
- **Model**: `glm-4-flash`
- **特点**: 响应速度快，适合实时对话

### 2. Moonshot (月之暗面)
- **API Base**: `https://api.moonshot.cn/v1`
- **API Key**: `sk-62PF3RVphYW8dByWOp7RYOgoRXhHSRI99gXrwcg93JyLuLWb`
- **Model**: `moonshot-v1-32k`
- **特点**: 长上下文支持，适合复杂推理

## API功能

### 1. 生成谜语
```dart
final aiService = AIService();
String? result = await aiService.generateRiddle('字谜');
```

### 2. 猜谜提示
```dart
String? hint = await aiService.getHint('谜面', '谜底');
```

### 3. 解释谜语
```dart
String? explanation = await aiService.explainRiddle('谜面', '谜底');
```

### 4. 作品名解析
```dart
// 解析简称对应的作品
String? workName = await aiService.resolveWorkName('三体');

// 检查是否为作品名
String? result = await aiService.checkWorkName('三体');
```

### 5. 通用对话
```dart
String? response = await aiService.chat('你好，讲个谜语故事');
```

## 切换AI提供商

在AI助手界面右上角点击设置图标，可以切换使用的AI模型：
- GLM-4-Flash (默认，速度快)
- Moonshot (长上下文)

## 故障排除

### API调用失败
1. 检查网络连接
2. 确认API密钥是否有效
3. 查看控制台输出的错误信息

### 模型切换不生效
1. 确保网络连接正常
2. 切换后重新发送消息

## 注意事项

⚠️ **重要提示**:
- API密钥内置在客户端代码中，生产环境建议使用后端代理
- 请注意API调用次数和费用
- 遵守各AI服务商的使用条款

## Prompt模板

### 作品名解析Prompt
```
将以下简称扩展为完整作品名。规则：
1. 如果本身就是完整作品名则原样回复
2. 不要截断或缩短，例如"聊斋志异之画皮"不应缩短为"聊斋志异"
3. 如果出自某个作品则回复作品名
4. 只回复中文简体名称，不要解释，不要多余文字
输入：{keyword}
```

### 作品名检查Prompt
```
下面的简称是作品名吗，如果不是的话它出自哪个作品，只回复作品的中文简体名称不要多余文字：
{keyword}
```

## 修改API配置

如需修改API密钥或模型，请编辑：
`lib/services/ai_service.dart`

```dart
static const String glmApiKey = '你的API_KEY';
static const String moonshotApiKey = '你的API_KEY';
```
