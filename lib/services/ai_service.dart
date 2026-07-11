import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/ai_model_config.dart';

/// AI 服务（支持动态切换模型）
class AIService {
  static final AIService _instance = AIService._internal();
  static AIService get instance => _instance;
  
  final Dio _dio = Dio();
  final AIModelConfig _config = AIModelConfig();

  AIService._internal();

  /// 获取当前使用的模型
  AIModel? get currentModel => _config.currentModel;

  /// 初始化（必须在使用前调用）
  Future<void> init() async {
    await _config.init();
  }

  /// 生成魔法笔记回应（静态方法，兼容旧代码）
  static Future<String> generateMagicResponse(String userInput) async {
    final service = AIService.instance;
    final prompt = '''
用户写下：$userInput

请以魔法笔记本的精灵身份给出一段温暖、神秘、富有哲理的回应。
要求：
1. 语言优美，富有诗意
2. 包含一些魔法/神秘的元素
3. 鼓励用户，给予启发
4. 字数在80-150字之间
5. 不要太直白，要有意境
''';
    
    final result = await service._callAI(prompt);
    return result ?? "✨ 你的文字已融入魔法书页，化作星光洒入宇宙深处...";
  }

  /// 生成谜语
  Future<String?> generateRiddle(String category) async {
    final prompt = '''
请生成一个有趣的$category谜语。
要求：
1. 谜面要生动有趣，有一定的迷惑性
2. 谜底要准确
3. 格式：先写谜面，然后换行写"谜底：xxx"
4. 如果有提示也可以加上
''';
    return await _callAI(prompt);
  }

  /// 猜谜语提示
  Future<String?> getHint(String question, String answer) async {
    final prompt = '''
谜面是：$question
谜底是：$answer

请给一个巧妙的提示，帮助用户猜出谜底，但不要直接说答案。
要求：
1. 提示要隐晦但有帮助
2. 不要直接说出答案
3. 简短精炼，不超过30字
''';
    return await _callAI(prompt);
  }

  /// 解释谜语
  Future<String?> explainRiddle(String question, String answer) async {
    final prompt = '''
请解释这个谜语的巧妙之处：
谜面：$question
谜底：$answer

要求：
1. 分析谜语的构成（谐音、双关、拆字等）
2. 说明为什么这个谜底是正确的
3. 用通俗易懂的语言解释
''';
    return await _callAI(prompt);
  }

  /// 解析作品名简称
  Future<String?> resolveWorkName(String keyword) async {
    final prompt = '''
将以下简称扩展为完整作品名。规则：
1. 如果本身就是完整作品名则原样回复
2. 不要截断或缩短，例如"聊斋志异之画皮"不应缩短为"聊斋志异"
3. 如果出自某个作品则回复作品名
4. 只回复中文简体名称，不要解释，不要多余文字
输入：$keyword
''';
    return await _callAI(prompt);
  }

  /// 检查是否是作品名
  Future<String?> checkWorkName(String keyword) async {
    final prompt = '''
下面的简称是作品名吗，如果不是的话它出自哪个作品，只回复作品的中文简体名称不要多余文字：
$keyword
''';
    return await _callAI(prompt);
  }

  /// 通用对话
  Future<String?> chat(String message) async {
    return await _callAI(message);
  }

  /// 调用 AI API（自动使用当前配置的模型）
  Future<String?> _callAI(String prompt) async {
    final model = _config.currentModel;
    if (model == null) {
      print('错误：没有配置 AI 模型');
      return null;
    }

    try {
      final response = await _dio.post(
        '${model.apiBase}/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${model.apiKey}',
          },
        ),
        data: jsonEncode({
          'model': model.modelName,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': model.temperature ?? 0.7,
          'max_tokens': model.maxTokens ?? 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['choices'][0]['message']['content'];
      }
      return null;
    } catch (e) {
      print('AI API调用失败 (${model.name}): $e');
      return null;
    }
  }

  /// 测试 API 连接
  Future<bool> testConnection(AIModel model) async {
    try {
      final response = await _dio.post(
        '${model.apiBase}/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${model.apiKey}',
          },
        ),
        data: jsonEncode({
          'model': model.modelName,
          'messages': [
            {'role': 'user', 'content': '你好'}
          ],
          'max_tokens': 10,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('API 测试失败: $e');
      return false;
    }
  }
}
