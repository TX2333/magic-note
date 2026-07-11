import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/ai_model_config.dart';

/// AI 模型配置管理界面
class AIModelConfigScreen extends StatefulWidget {
  const AIModelConfigScreen({super.key});

  @override
  State<AIModelConfigScreen> createState() => _AIModelConfigScreenState();
}

class _AIModelConfigScreenState extends State<AIModelConfigScreen> {
  final AIModelConfig _config = AIModelConfig();
  final List<AIModel> _presetModels = AIModelConfig.getPresetModels();

  @override
  void initState() {
    super.initState();
    _config.init();
  }

  /// 显示添加/编辑模型对话框
  void _showModelDialog({AIModel? model}) {
    final isEdit = model != null;
    final nameController = TextEditingController(text: model?.name ?? '');
    final apiKeyController = TextEditingController(text: model?.apiKey ?? '');
    final apiBaseController = TextEditingController(text: model?.apiBase ?? '');
    final modelNameController = TextEditingController(text: model?.modelName ?? '');
    final providerController = TextEditingController(text: model?.provider ?? 'OpenAI-Compatible');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0d1a0d),
        title: Text(isEdit ? '编辑模型' : '添加自定义模型', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '模型显示名称',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  hintText: '例如：我的自定义模型',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF39FF14))),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: providerController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '服务商',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  hintText: '例如：OpenAI, GLM, Qwen 等',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF64FFDA))),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiBaseController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'API 地址 (Base URL)',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  hintText: 'https://api.example.com/v1',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF64FFDA))),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'API Key',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  hintText: 'sk-...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF64FFDA))),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: modelNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '模型名称 (Model Name)',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  hintText: '例如：gpt-4o-mini',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF64FFDA))),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  apiKeyController.text.isEmpty ||
                  apiBaseController.text.isEmpty ||
                  modelNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写所有字段')),
                );
                return;
              }

              final newModel = AIModel(
                id: isEdit
                    ? model.id
                    : 'custom-${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text,
                provider: providerController.text,
                apiKey: apiKeyController.text,
                apiBase: apiBaseController.text,
                modelName: modelNameController.text,
              );

              if (isEdit) {
                await _config.updateModel(newModel);
              } else {
                await _config.addModel(newModel);
              }

              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF64FFDA)),
            child: Text(isEdit ? '保存' : '添加', style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// 快速添加预设模型
  void _quickAddPresetModel(AIModel preset) {
    final model = preset.copyWith(isEnabled: true);
    _showModelDialog(model: model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 模型配置', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF64FFDA)),
            onPressed: () => _showModelDialog(),
            tooltip: '添加自定义模型',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _config,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 当前使用的模型
              Card(
                color: const Color(0xFF16213E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF64FFDA), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.radio_button_checked, color: Color(0xFF64FFDA)),
                          const SizedBox(width: 8),
                          const Text('当前使用的模型',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_config.currentModel != null)
                        ListTile(
                          title: Text(_config.currentModel!.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text('${_config.currentModel!.provider} · ${_config.currentModel!.modelName}',
                              style: TextStyle(color: Colors.grey.shade400)),
                          trailing: const Icon(Icons.check_circle, color: Color(0xFF64FFDA)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 已配置的模型列表
              const Text('已配置的模型',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              ..._config.allModels.map((model) {
                return Card(
                  color: const Color(0xFF16213E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade800),
                  ),
                  child: ListTile(
                    leading: Radio<String>(
                      value: model.id,
                      groupValue: _config.currentModelId,
                      activeColor: const Color(0xFF64FFDA),
                      onChanged: (value) {
                        if (value != null) _config.setCurrentModel(value);
                      },
                    ),
                    title: Text(model.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${model.provider} · ${model.modelName}',
                        style: TextStyle(color: Colors.grey.shade400)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Color(0xFF64FFDA)),
                          onPressed: () => _showModelDialog(model: model),
                          tooltip: '编辑',
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: model.apiKey));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('API Key 已复制到剪贴板')),
                            );
                          },
                          tooltip: '复制 API Key',
                        ),
                        if (_config.allModels.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1A1A2E),
                                  title: const Text('删除模型', style: TextStyle(color: Colors.white)),
                                  content: Text('确定要删除模型"${model.name}"吗？', style: const TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('取消', style: TextStyle(color: Colors.grey)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _config.deleteModel(model.id);
                                        if (mounted) Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                      child: const Text('删除', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            tooltip: '删除',
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              // 快速添加预设模型
              const Text('快速添加预设模型',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetModels.map((preset) {
                  return ElevatedButton.icon(
                    onPressed: () => _quickAddPresetModel(preset),
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFF64FFDA)),
                    label: Text(preset.name, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16213E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade700),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // 配置说明
              Card(
                color: const Color(0xFF64FFDA).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: const Color(0xFF64FFDA).withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Color(0xFF64FFDA)),
                          const SizedBox(width: 8),
                          const Text('配置说明',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64FFDA))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• 所有 OpenAI 兼容的 API 都可以添加\n'
                        '• 只需要填入 API Base URL、API Key 和模型名\n'
                        '• 配置保存在本地，不会上传到任何服务器\n'
                        '• 点击模型名称即可切换当前使用的模型',
                        style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
