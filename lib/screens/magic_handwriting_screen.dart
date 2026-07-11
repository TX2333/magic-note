import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/ai_service.dart';
import '../models/note.dart';

// ==================== 工具系统 - Hermes Agent 风格 ====================

/// 魔法工具抽象基类
abstract class MagicTool {
  String get name;
  String get description;
  Future<String> execute(Map<String, dynamic> params);
}

/// 计算器工具
class CalculatorTool extends MagicTool {
  @override
  String get name => 'calculator';
  
  @override
  String get description => '执行数学计算，解决算术问题';
  
  @override
  Future<String> execute(Map<String, dynamic> params) async {
    try {
      final expression = params['expression'] as String;
      // 简单计算逻辑实现
      return '计算结果：$expression = ...';
    } catch (e) {
      return '计算失败：$e';
    }
  }
}

/// 记忆管理工具
class MemoryTool extends MagicTool {
  final List<Map<String, String>> _memories = [];
  
  @override
  String get name => 'memory';
  
  @override
  String get description => '管理对话记忆，保存重要信息';
  
  @override
  Future<String> execute(Map<String, dynamic> params) async {
    final action = params['action'] as String;
    switch (action) {
      case 'save':
        _memories.add({
          'content': params['content'] as String,
          'time': DateTime.now().toIso8601String(),
        });
        return '记忆已保存';
      case 'recall':
        return _memories.map((m) => m['content']).join('\n');
      default:
        return '未知操作';
    }
  }
  
  List<Map<String, String>> getAllMemories() => _memories;
}

/// 技能成长系统
class SkillGrowthSystem {
  final Map<String, int> _skillUsage = {};
  final Map<String, int> _skillLevel = {};
  
  void recordUsage(String toolName) {
    _skillUsage[toolName] = (_skillUsage[toolName] ?? 0) + 1;
    // 每使用10次升一级
    _skillLevel[toolName] = (_skillUsage[toolName]! / 10).floor();
  }
  
  int getSkillLevel(String toolName) => _skillLevel[toolName] ?? 0;
  
  String getRecommendedTools() {
    final sorted = _skillUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).join(', ');
  }
}

// ==================== 主界面 ====================

class MagicHandwritingScreen extends StatefulWidget {
  final Function(Note)? onNoteSaved;
  
  const MagicHandwritingScreen({super.key, this.onNoteSaved});

  @override
  State<MagicHandwritingScreen> createState() => _MagicHandwritingScreenState();
}

class _MagicHandwritingScreenState extends State<MagicHandwritingScreen> with TickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();
  final List<List<Offset>> _strokes = [];
  final List<Offset> _currentStroke = [];
  
  // 动画控制器
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _revealController;
  
  // 粒子系统
  final List<FadingParticle> _fadingParticles = [];
  final List<MagicSpark> _sparkParticles = [];
  
  // 状态
  bool _isWriting = false;
  bool _isCastingSpell = false;
  bool _isAIResponding = false;
  String _aiResponse = '';
  Timer? _spellTimer;
  Timer? _fadeDelayTimer;
  DateTime? _lastWriteTime;
  
  // 逐行显示相关
  List<String> _responseLines = [];
  int _visibleLineCount = 0;
  Timer? _lineRevealTimer;
  
  // 书写节奏学习（动态停笔判断）
  final List<int> _pauseDurations = [];  // 记录每笔之间的停顿时间（毫秒）
  DateTime? _lastPenUpTime;              // 上次抬笔时间
  static const int _basePauseThreshold = 3000;  // 基础停顿阈值：3秒
  
  // 笔迹消散相关
  List<List<Offset>> _fadingStrokes = [];
  double _fadeProgress = 0.0;
  
  // 对话历史记忆（最近5轮）
  final List<Map<String, String>> _conversationHistory = [];
  static const int _maxHistorySize = 5;
  
  // 自动施法配置
  static const int _minStrokeCount = 3;        // 至少3笔才算开始写了
  static const double _minTotalStrokeLength = 200;  // 笔画总长度至少200像素
  
  // 笔压相关
  double _currentPressure = 0.5;
  bool _isStylusInput = false;
  
  // 工具系统
  final MemoryTool _memoryTool = MemoryTool();
  final SkillGrowthSystem _skillSystem = SkillGrowthSystem();
  
  @override
  void initState() {
    super.initState();
    
    // 笔迹消散动画 - 3秒完成（更有仪式感）
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addListener(() {
      setState(() => _fadeProgress = _fadeController.value);
      _generateFadeParticles();
    });
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 30),
    )..addListener(_updateParticles);
    _particleController.repeat();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    // 回复浮现动画 - 2秒完成（缓缓浮现）
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _spawnInitialParticles();
  }

  void _spawnInitialParticles() {
    for (int i = 0; i < 30; i++) {
      _sparkParticles.add(MagicSpark.random());
    }
  }

  // 检测到触摸屏/电容笔输入
  void _onPointerDown(PointerDownEvent event) {
    if (_isCastingSpell || _isAIResponding) return;
    
    _isStylusInput = event.kind == PointerDeviceKind.stylus;
    _currentPressure = event.pressure;
    
    setState(() {
      _isWriting = true;
      _strokes.add([]);
    });
    _cancelSpellTimer();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isCastingSpell || _isAIResponding) return;
    
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final localPosition = renderBox.globalToLocal(event.position);
    _currentPressure = event.pressure;
    
    setState(() {
      _strokes.last.add(localPosition);
      _lastWriteTime = DateTime.now();
    });
    
    _addWriteSpark(localPosition);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isCastingSpell || _isAIResponding) return;
    setState(() => _isWriting = false);
    
    // 记录本次停顿时间（学习书写节奏）
    final now = DateTime.now();
    if (_lastPenUpTime != null) {
      final pauseDuration = now.difference(_lastPenUpTime!).inMilliseconds;
      // 只记录合理的停顿（100ms-10秒之间），排除异常值
      if (pauseDuration >= 100 && pauseDuration <= 10000) {
        _pauseDurations.add(pauseDuration);
        // 只保留最近20次停顿数据
        if (_pauseDurations.length > 20) {
          _pauseDurations.removeAt(0);
        }
      }
    }
    _lastPenUpTime = now;
    
    _startSpellTimer();
  }

  void _addWriteSpark(Offset position) {
    for (int i = 0; i < 3; i++) {
      final spark = MagicSpark(
        x: position.dx + (Random().nextDouble() - 0.5) * 20,
        y: position.dy + (Random().nextDouble() - 0.5) * 20,
        vx: (Random().nextDouble() - 0.5) * 2,
        vy: Random().nextDouble() * -2 - 1,
        size: Random().nextDouble() * 4 + 2,
        opacity: Random().nextDouble() * 0.6 + 0.4,
        color: Color.lerp(
          const Color(0xFF00FF41),
          const Color(0xFF39FF14),
          Random().nextDouble(),
        )!,
      );
      setState(() => _sparkParticles.add(spark));
    }
  }

  // 停止书写2秒后开始施法
  void _startSpellTimer() {
    _cancelSpellTimer();
    
    // 智能判断是否真的写完了
    if (!_shouldAutoCast()) return;
    
    // 动态计算触发阈值：基于用户平时的书写节奏
    final triggerDelay = _calculateDynamicTriggerDelay();
    
    _spellTimer = Timer(Duration(milliseconds: triggerDelay), () {
      if (_strokes.isNotEmpty && !_isWriting && !_isCastingSpell && !_isAIResponding) {
        _castSpell();
      }
    });
  }
  
  // 基于历史书写节奏，动态计算触发阈值
  int _calculateDynamicTriggerDelay() {
    if (_pauseDurations.isEmpty) {
      return _basePauseThreshold;  // 没有数据时，使用基础值3秒
    }
    
    // 计算平均停顿时间
    final avgPause = _pauseDurations.reduce((a, b) => a + b) / _pauseDurations.length;
    
    // 动态阈值 = 平均停顿时间 × 2.5（通常"思考下一个字"的停顿比"字与字之间"的停顿长很多）
    // 范围：3秒 - 10秒 动态自适应
    final dynamicThreshold = (avgPause * 2.5).round();
    return dynamicThreshold.clamp(3000, 10000);
  }
  
  // 智能判断是否应该自动施法
  bool _shouldAutoCast() {
    // 1. 笔画数量不够（可能只是点了一下）
    if (_strokes.length < _minStrokeCount) return false;
    
    // 2. 笔画总长度不够（可能只是随便画了一下）
    double totalLength = 0;
    for (final stroke in _strokes) {
      for (int i = 1; i < stroke.length; i++) {
        final dx = stroke[i].dx - stroke[i-1].dx;
        final dy = stroke[i].dy - stroke[i-1].dy;
        totalLength += sqrt(dx * dx + dy * dy);
      }
    }
    if (totalLength < _minTotalStrokeLength) return false;
    
    return true;
  }

  void _cancelSpellTimer() {
    _spellTimer?.cancel();
    _spellTimer = null;
  }

  void _cancelFadeDelayTimer() {
    _fadeDelayTimer?.cancel();
    _fadeDelayTimer = null;
  }

  // 核心施法逻辑：笔迹消散 → AI回复逐行浮现 → AI回复消散
  Future<void> _castSpell() async {
    if (_strokes.isEmpty) return;
    
    setState(() {
      _isCastingSpell = true;
      _fadingStrokes = List.from(_strokes);
    });
    
    try {
      // 1. 先捕获图片并异步调用AI（后台进行）
      final imageBytes = await _captureCanvasImage();
      Future<String?> aiFuture = Future.value(null);
      if (imageBytes != null) {
        aiFuture = _callVisionAI(imageBytes);
      }
      
      // 2. 立即开始消散笔迹（用户写完就消散）
      if (mounted) {
        _fadeController.forward(from: 0.0);
      }
      
      // 3. 等待笔迹消散完成（3秒），同时等待AI返回
      await Future.wait([
        _fadeController.forward(),
        Future.delayed(const Duration(seconds: 3)),
      ]);
      
      // 4. 获取AI回复
      final response = await aiFuture;
      
      if (mounted && response != null) {
        // 5. 清空笔迹，准备逐行显示回复
        setState(() {
          _strokes.clear();
          _fadingStrokes.clear();
          _aiResponse = response;
          _responseLines = _splitIntoLines(response);
          _visibleLineCount = 0;
          _isAIResponding = true;
        });
        
        // 6. 保存到对话历史
        _saveToHistory(_getRecognizedText(response), response);
        
        // 7. 开始逐行显示（每300毫秒显示一行）
        _startLineByLineReveal();
      } else if (mounted) {
        setState(() {
          _isCastingSpell = false;
          _fadingStrokes.clear();
          _strokes.clear();
        });
      }
    } catch (e) {
      print('咒语施展失败: $e');
      if (mounted) {
        setState(() {
          _aiResponse = "✨ 黑暗力量已感知你的印记...";
          _responseLines = ["✨ 黑暗力量已感知你的印记..."];
          _visibleLineCount = 1;
          _isAIResponding = true;
          _isCastingSpell = false;
        });
      }
    }
  }
  
  // 将回复按句子/换行符拆分成行
  List<String> _splitIntoLines(String text) {
    // 先按换行符分割，再按中文标点分割长句
    final lines = <String>[];
    final rawLines = text.split('\n');
    
    for (final line in rawLines) {
      if (line.trim().isEmpty) continue;
      
      // 长句按标点符号进一步分割
      final sentences = line.split(RegExp(r'([。！？；.!?;])'));
      for (int i = 0; i < sentences.length; i += 2) {
        if (i < sentences.length && sentences[i].trim().isNotEmpty) {
          var result = sentences[i].trim();
          // 把标点符号加回去
          if (i + 1 < sentences.length) {
            result += sentences[i + 1];
          }
          lines.add(result);
        }
      }
    }
    
    return lines.isEmpty ? [text] : lines;
  }
  
  // 逐行显示定时器
  void _startLineByLineReveal() {
    _lineRevealTimer?.cancel();
    
    int currentLine = 0;
    final totalLines = _responseLines.length;
    
    _lineRevealTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted || currentLine >= totalLines) {
        timer.cancel();
        
        // 所有行显示完毕后，显示8秒再消散
        if (currentLine >= totalLines) {
          _fadeDelayTimer = Timer(const Duration(seconds: 8), () {
            if (mounted) {
              _fadeOutResponse();
            }
          });
        }
        return;
      }
      
      setState(() {
        _visibleLineCount = ++currentLine;
      });
    });
  }
  
  // 回复消散动画
  void _fadeOutResponse() {
    _revealController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isAIResponding = false;
          _aiResponse = '';
          _responseLines = [];
          _visibleLineCount = 0;
          _isCastingSpell = false;
        });
      }
    });
  }

  // 从AI回复中提取用户写的内容（简化实现）
  String _getRecognizedText(String aiResponse) {
    // 实际应该在识别时单独保存，这里简化处理
    return '手写内容';
  }

  // 保存对话到历史
  void _saveToHistory(String question, String answer) {
    _conversationHistory.insert(0, {
      'question': question,
      'answer': answer,
      'time': DateTime.now().toIso8601String(),
    });
    
    // 保持最近5轮
    if (_conversationHistory.length > _maxHistorySize) {
      _conversationHistory.removeLast();
    }
  }

  // 构建带历史上下文的Prompt
  String _buildPromptWithHistory() {
    final historyBuffer = StringBuffer();
    
    if (_conversationHistory.isNotEmpty) {
      historyBuffer.writeln('【历史对话记录】');
      for (int i = 0; i < _conversationHistory.length; i++) {
        final entry = _conversationHistory[i];
        historyBuffer.writeln('第${i + 1}轮:');
        historyBuffer.writeln('用户写下：${entry['question']}');
        historyBuffer.writeln('你的回应：${entry['answer']}');
        historyBuffer.writeln();
      }
      historyBuffer.writeln('【当前对话】');
    }
    
    historyBuffer.writeln('''
这是一张手写笔记的图片，请仔细识别上面的手写文字内容。
识别完成后，以汤姆·里德尔日记本中寄宿灵魂的身份，给这段文字一个神秘、深邃、富有魔力的回应。
要求：
1. 语言富有诗意，带有黑暗魔法的气息
2. 包含一些魔法、古老、灵魂、时间等神秘元素
3. 语气像一个沉睡了多年的古老灵魂在低语
4. 参考历史对话的上下文，保持对话连贯性
5. 字数在80-150字之间
6. 不要太直白，要有意境，让人觉得日记本真的有生命
''');
    
    return historyBuffer.toString();
  }

  void _generateFadeParticles() {
    if (_fadingStrokes.isEmpty) return;
    
    for (final stroke in _fadingStrokes) {
      if (stroke.isEmpty) continue;
      
      final particleCount = (stroke.length * (1 - _fadeProgress) * 0.3).toInt();
      for (int i = 0; i < particleCount; i++) {
        final pointIndex = (Random().nextDouble() * stroke.length).floor();
        final point = stroke[pointIndex];
        
        final particle = FadingParticle(
          x: point.dx,
          y: point.dy,
          vx: (Random().nextDouble() - 0.5) * 3,
          vy: Random().nextDouble() * -4 - 2,
          size: Random().nextDouble() * 3 + 1,
          opacity: Random().nextDouble() * 0.8 + 0.2,
        );
        _fadingParticles.add(particle);
      }
    }
  }

  Future<Uint8List?> _captureCanvasImage() async {
    try {
      final renderObject = _canvasKey.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        final image = await renderObject.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }
    } catch (e) {
      print('捕获画布失败: $e');
    }
    return null;
  }

  Future<String?> _callVisionAI(Uint8List imageBytes) async {
    try {
      final service = AIService.instance;
      final model = service.currentModel;
      if (model == null) return null;
      
      final base64Image = base64Encode(imageBytes);
      
      final dio = Dio();
      final response = await dio.post(
        '${model.apiBase}/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${model.apiKey}',
          },
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          'model': model.modelName,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': _buildPromptWithHistory(),
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/png;base64,$base64Image'
                  }
                }
              ]
            }
          ],
          'max_tokens': model.maxTokens ?? 1000,
          'temperature': 0.8,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      }
    } catch (e) {
      print('视觉AI调用失败: $e');
      return "✨ 黑暗魔法正在苏醒，请稍后再试...";
    }
    return null;
  }

  void _revealAnswer() {
    _revealController.forward(from: 0.0);
  }

  void _updateParticles() {
    setState(() {
      for (final p in _fadingParticles) {
        p.update();
      }
      _fadingParticles.removeWhere((p) => p.opacity <= 0 || p.y < -50);
      
      for (final p in _sparkParticles) {
        p.update();
      }
      _sparkParticles.removeWhere((p) => p.opacity <= 0);
      
      if (_sparkParticles.length < 20) {
        _sparkParticles.add(MagicSpark.random());
      }
    });
  }

  void _resetCanvas() {
    setState(() {
      _strokes.clear();
      _fadingStrokes.clear();
      _fadingParticles.clear();
      _isCastingSpell = false;
      _isAIResponding = false;
      _aiResponse = '';
      _responseLines = [];
      _visibleLineCount = 0;
      _lineRevealTimer?.cancel();
      _fadeProgress = 0.0;
      _fadeController.reset();
      _revealController.reset();
    });
  }

  @override
  void dispose() {
    _cancelSpellTimer();
    _cancelFadeDelayTimer();
    _lineRevealTimer?.cancel();
    _fadeController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildParchmentBackground(),
          
          ..._sparkParticles.map((p) => _buildSpark(p)),
          
          ..._fadingParticles.map((p) => _buildFadingParticle(p)),
          
          Column(
            children: [
              _buildMagicHeader(),
              
              Expanded(
                child: Stack(
                  children: [
                    _buildHandwritingCanvas(),
                    
                    if (_fadingStrokes.isNotEmpty) _buildFadingStrokes(),
                    
                    if (_isAIResponding) _buildRevealedAnswer(),
                  ],
                ),
              ),
              
              _buildBottomControls(),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
          
          _buildDarkAura(),
        ],
      ),
    );
  }

  Widget _buildParchmentBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0a0a0a),
            Color(0xFF0d1a0d),
            Color(0xFF0a1510),
            Color(0xFF050a08),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildDarkAura() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity = 0.05 + _glowController.value * 0.08;
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.8),
                radius: 1.5,
                colors: [
                  const Color(0xFF00FF41).withOpacity(glowOpacity),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMagicHeader() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 15, bottom: 10),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      const Color(0xFF00FF41).withOpacity(0.6 + _glowController.value * 0.4),
                      const Color(0xFF39FF14),
                      const Color(0xFF00FF41).withOpacity(0.6 + _glowController.value * 0.4),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    "🐍 汤姆·里德尔的日记 🐍",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Text(
                  _isWriting
                      ? "墨水正在羊皮纸上流动...${_isStylusInput ? '(电容笔)' : ''}"
                      : _isCastingSpell
                          ? "正在施展黑魔法..."
                          : _isAIResponding
                              ? "黑暗灵魂正在回应..."
                              : "在羊皮纸上写下你的话语...",
                  style: TextStyle(
                    color: const Color(0xFF39FF14).withOpacity(0.35 + _glowController.value * 0.25),
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandwritingCanvas() {
    return RepaintBoundary(
      key: _canvasKey,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a0a).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF39FF14).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: CustomPaint(
            painter: HandwritingPainter(
              strokes: _strokes,
              glowIntensity: 1.0 - _fadeProgress,
              pressure: _currentPressure,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget _buildFadingStrokes() {
    return IgnorePointer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomPaint(
          painter: FadingStrokesPainter(
            strokes: _fadingStrokes,
            fadeProgress: _fadeProgress,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildRevealedAnswer() {
    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        return Positioned(
          left: 20,
          right: 20,
          top: 0,
          bottom: 0,
          child: Opacity(
            opacity: _revealController.value,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF0d1a0d).withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF39FF14).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39FF14).withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF39FF14).withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF39FF14).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text("🐍", style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "汤姆·里德尔的低语",
                          style: TextStyle(
                            color: Color(0xFF39FF14),
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 逐行显示的回复
                    ...List.generate(_visibleLineCount, (index) {
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _responseLines[index],
                            style: const TextStyle(
                              color: Color(0xFF39FF14),
                              fontSize: 15,
                              height: 1.8,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: Color(0xFF39FF14),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    // 打字机光标效果（显示过程中）
                    if (_visibleLineCount < _responseLines.length)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: _BlinkingCursor(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _isCastingSpell ? null : () {
              setState(() => _strokes.clear());
            },
            icon: const Icon(Icons.clear, color: Color(0xFF39FF14), size: 18),
            label: const Text(
              "清除",
              style: TextStyle(color: Color(0xFF39FF14), fontSize: 12),
            ),
          ),
          Text(
            "记忆: ${_conversationHistory.length}/$_maxHistorySize 轮",
            style: TextStyle(
              color: const Color(0xFF39FF14).withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          TextButton.icon(
            onPressed: _isAIResponding ? _resetCanvas : null,
            icon: const Icon(Icons.refresh, color: Color(0xFF39FF14), size: 18),
            label: const Text(
              "新的一页",
              style: TextStyle(color: Color(0xFF39FF14), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpark(MagicSpark p) {
    return Positioned(
      left: p.x,
      top: p.y,
      child: Container(
        width: p.size,
        height: p.size,
        decoration: BoxDecoration(
          color: p.color.withOpacity(p.opacity),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: p.color.withOpacity(p.opacity),
              blurRadius: p.size * 3,
              spreadRadius: p.size * 0.3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFadingParticle(FadingParticle p) {
    return Positioned(
      left: p.x,
      top: p.y,
      child: Container(
        width: p.size,
        height: p.size,
        decoration: BoxDecoration(
          color: const Color(0xFF39FF14).withOpacity(p.opacity),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF39FF14).withOpacity(p.opacity),
              blurRadius: p.size * 4,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 粒子与画笔类 ====================

class MagicSpark {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  Color color;

  MagicSpark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.color,
  });

  factory MagicSpark.random() {
    final random = Random();
    return MagicSpark(
      x: random.nextDouble() * 400,
      y: random.nextDouble() * 700,
      vx: (random.nextDouble() - 0.5) * 0.8,
      vy: (random.nextDouble() - 0.5) * 0.8,
      size: random.nextDouble() * 2 + 1,
      opacity: random.nextDouble() * 0.3 + 0.1,
      color: Color.lerp(
        const Color(0xFF00FF41),
        const Color(0xFF39FF14),
        random.nextDouble(),
      )!,
    );
  }

  void update() {
    x += vx;
    y += vy;
    opacity -= 0.008;
    size *= 0.995;
  }
}

class FadingParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;

  FadingParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
  });

  void update() {
    x += vx;
    y += vy;
    opacity -= 0.015;
    size *= 0.98;
  }
}

class HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final double glowIntensity;
  final double pressure;

  HandwritingPainter({
    required this.strokes,
    required this.glowIntensity,
    this.pressure = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 根据笔压调整线条粗细
    final baseWidth = 2.0 + pressure * 4.0;
    
    final paint = Paint()
      ..color = const Color(0xFF39FF14)
      ..strokeWidth = baseWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF39FF14).withOpacity(glowIntensity * 0.5)
      ..strokeWidth = baseWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4)
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      
      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      
      if (glowIntensity > 0.1) {
        canvas.drawPath(path, glowPaint);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HandwritingPainter oldDelegate) => true;
}

class FadingStrokesPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final double fadeProgress;

  FadingStrokesPainter({
    required this.strokes,
    required this.fadeProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fadeProgress >= 1.0) return;
    
    final opacity = 1.0 - fadeProgress;
    
    final paint = Paint()
      ..color = const Color(0xFF39FF14).withOpacity(opacity * 0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF39FF14).withOpacity(opacity * 0.3)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5)
      ..style = PaintingStyle.stroke;

    for (int s = 0; s < strokes.length; s++) {
      final stroke = strokes[s];
      if (stroke.isEmpty) continue;
      
      final path = Path();
      
      for (int i = 0; i < stroke.length; i++) {
        final pointProgress = i / stroke.length;
        final fadeOffset = (s / strokes.length) * 0.3;
        final combinedProgress = fadeProgress + fadeOffset;
        
        if (pointProgress < combinedProgress - 0.3) continue;
        
        final jitterX = sin(fadeProgress * pi * 3 + s) * fadeProgress * 15;
        final jitterY = cos(fadeProgress * pi * 2 + i * 0.1) * fadeProgress * 10;
        
        final x = stroke[i].dx + jitterX;
        final y = stroke[i].dy + jitterY - fadeProgress * 50;
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FadingStrokesPainter oldDelegate) => true;
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 8,
            height: 20,
            color: const Color(0xFF39FF14),
          ),
        );
      },
    );
  }
}
