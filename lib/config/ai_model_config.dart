
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AI 模型配置
class AIModel {
  final String id;
  final String name;
  final String provider;
  final String apiKey;
  final String apiBase;
  final String modelName;
  final bool isEnabled;
  final int? maxTokens;
  final double? temperature;

  AIModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.apiKey,
    required this.apiBase,
    required this.modelName,
    this.isEnabled = true,
    this.maxTokens = 1000,
    this.temperature = 0.7,
  });

  AIModel copyWith({
    String? id,
    String? name,
    String? provider,
    String? apiKey,
    String? apiBase,
    String? modelName,
    bool? isEnabled,
    int? maxTokens,
    double? temperature,
  }) {
    return AIModel(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      apiBase: apiBase ?? this.apiBase,
      modelName: modelName ?? this.modelName,
      isEnabled: isEnabled ?? this.isEnabled,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'apiKey': apiKey,
      'apiBase': apiBase,
      'modelName': modelName,
      'isEnabled': isEnabled,
      'maxTokens': maxTokens,
      'temperature': temperature,
    };
  }

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      id: json['id'],
      name: json['name'],
      provider: json['provider'],
      apiKey: json['apiKey'],
      apiBase: json['apiBase'],
      modelName: json['modelName'],
      isEnabled: json['isEnabled'] ?? true,
      maxTokens: json['maxTokens'],
      temperature: json['temperature'],
    );
  }
}

/// AI 模型配置管理器（单例）
class AIModelConfig extends ChangeNotifier {
  static final AIModelConfig _instance = AIModelConfig._internal();
  factory AIModelConfig() => _instance;
  AIModelConfig._internal();

  List<AIModel> _models = [];
  String _currentModelId = '';

  List<AIModel> get models => _models.where((m) => m.isEnabled).toList();
  List<AIModel> get allModels => _models;
  AIModel? get currentModel =>
      _models.firstWhere((m) => m.id == _currentModelId, orElse: () => _models.first);
  String get currentModelId => _currentModelId;

  /// 初始化预设模型
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('ai_models');
    final currentId = prefs.getString('current_model_id');

    if (saved != null && saved.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(saved);
        _models = list.map((item) => AIModel.fromJson(item)).toList();
      } catch (e) {
        _models = _getDefaultModels();
      }
    } else {
      _models = _getDefaultModels();
    }

    if (currentId != null && currentId.isNotEmpty) {
      _currentModelId = currentId;
    } else if (_models.isNotEmpty) {
      _currentModelId = _models.first.id;
    }

    notifyListeners();
  }

  /// 预设模型
  List<AIModel> _getDefaultModels() {
    return [
      AIModel(
        id: 'qwen3-vl-siliconflow',
        name: 'Qwen3-VL-32B (硅基流动-免费视觉)',
        provider: 'SiliconFlow',
        apiKey: 'sk-wkazmjpxhnlalqzicnwlkbfpclitfvckiicatuybzyrqztmq',
        apiBase: 'https://api.siliconflow.cn/v1',
        modelName: 'Qwen/Qwen3-VL-32B-Instruct',
        maxTokens: 1000,
        temperature: 0.8,
      ),
      AIModel(
        id: 'glm-4-flash',
        name: 'GLM-4-Flash (智谱-纯文本)',
        provider: 'GLM',
        apiKey: '9f9a917e3cbf480291bfe80b2d8ed744.8RW6t1WfbnNJz7Oo',
        apiBase: 'https://open.bigmodel.cn/api/paas/v4',
        modelName: 'glm-4-flash',
        maxTokens: 1000,
        temperature: 0.7,
      ),
      AIModel(
        id: 'moonshot-v1-32k',
        name: 'Moonshot-v1-32k (月之暗面-纯文本)',
        provider: 'Moonshot',
        apiKey: 'sk-62PF3RVphYW8dByWOp7RYOgoRXhHSRI99gXrwcg93JyLuLWb',
        apiBase: 'https://api.moonshot.cn/v1',
        modelName: 'moonshot-v1-32k',
        maxTokens: 2000,
        temperature: 0.7,
      ),
    ];
  }

  /// 保存配置
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _models.map((m) => m.toJson()).toList();
    await prefs.setString('ai_models', jsonEncode(list));
    await prefs.setString('current_model_id', _currentModelId);
  }

  /// 添加自定义模型
  Future<void> addModel(AIModel model) async {
    _models.add(model);
    await _save();
    notifyListeners();
  }

  /// 更新模型
  Future<void> updateModel(AIModel model) async {
    final index = _models.indexWhere((m) => m.id == model.id);
    if (index != -1) {
      _models[index] = model;
      await _save();
      notifyListeners();
    }
  }

  /// 删除模型
  Future<void> deleteModel(String id) async {
    _models.removeWhere((m) => m.id == id);
    if (_currentModelId == id && _models.isNotEmpty) {
      _currentModelId = _models.first.id;
    }
    await _save();
    notifyListeners();
  }

  /// 切换当前模型
  Future<void> setCurrentModel(String id) async {
    _currentModelId = id;
    await _save();
    notifyListeners();
  }

  /// 快速添加 OpenAI 兼容模型
  Future<void> addOpenAICompatibleModel({
    required String name,
    required String apiKey,
    required String apiBase,
    required String modelName,
  }) async {
    final model = AIModel(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      provider: 'OpenAI-Compatible',
      apiKey: apiKey,
      apiBase: apiBase,
      modelName: modelName,
    );
    await addModel(model);
  }

  /// 预设常用模型（方便快速添加）
  static List<AIModel> getPresetModels() {
    return [
      AIModel(
        id: 'preset-qwen3-vl-72b',
        name: 'Qwen3-VL-72B (硅基流动-免费视觉)',
        provider: 'SiliconFlow',
        apiKey: '你的APIKey',
        apiBase: 'https://api.siliconflow.cn/v1',
        modelName: 'Qwen/Qwen3-VL-72B-Instruct',
        isEnabled: false,
      ),
      AIModel(
        id: 'preset-qwen3-vl-32b',
        name: 'Qwen3-VL-32B (硅基流动-免费视觉)',
        provider: 'SiliconFlow',
        apiKey: '你的APIKey',
        apiBase: 'https://api.siliconflow.cn/v1',
        modelName: 'Qwen/Qwen3-VL-32B-Instruct',
        isEnabled: false,
      ),
      AIModel(
        id: 'preset-qwen-vl-max',
        name: 'Qwen-VL-Max (硅基流动-免费视觉)',
        provider: 'SiliconFlow',
        apiKey: '你的APIKey',
        apiBase: 'https://api.siliconflow.cn/v1',
        modelName: 'Qwen/Qwen-VL-Max',
        isEnabled: false,
      ),
      AIModel(
        id: 'preset-gpt-4o-mini',
        name: 'GPT-4o-mini (OpenAI)',
        provider: 'OpenAI',
        apiKey: '你的APIKey',
        apiBase: 'https://api.openai.com/v1',
        modelName: 'gpt-4o-mini',
        isEnabled: false,
      ),
      AIModel(
        id: 'preset-qwen-plus',
        name: 'Qwen-Plus (通义千问)',
        provider: 'Qwen',
        apiKey: '你的APIKey',
        apiBase: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
        modelName: 'qwen-plus',
        isEnabled: false,
      ),
      AIModel(
        id: 'preset-doubao-pro',
        name: 'Doubao-Pro (豆包)',
        provider: 'Doubao',
        apiKey: '你的APIKey',
        apiBase: 'https://ark.cn-beijing.volces.com/api/v3',
        modelName: 'ep-20240805184157-xxxxx',
        isEnabled: false,
      ),
      AIModel(
        id: 'preset-deepseek-chat',
        name: 'DeepSeek-Chat (深度求索)',
        provider: 'DeepSeek',
        apiKey: '你的APIKey',
        apiBase: 'https://api.deepseek.com/v1',
        modelName: 'deepseek-chat',
        isEnabled: false,
      ),
      AIModel(
        id: 'preset-yi-large',
        name: 'Yi-Large (零一万物)',
        provider: 'Yi',
        apiKey: '你的APIKey',
        apiBase: 'https://api.lingyiwanwu.com/v1',
        modelName: 'yi-large',
        isEnabled: false,
      ),
    ];
  }
}
