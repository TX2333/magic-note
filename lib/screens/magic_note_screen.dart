import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/note.dart';

class MagicNoteScreen extends StatefulWidget {
  final Function(Note)? onNoteSaved;
  
  const MagicNoteScreen({super.key, this.onNoteSaved});

  @override
  State<MagicNoteScreen> createState() => _MagicNoteScreenState();
}

class _MagicNoteScreenState extends State<MagicNoteScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  
  late AnimationController _particleController;
  late AnimationController _smokeController;
  late AnimationController _glowController;
  final List<SmokeParticle> _smokeParticles = [];
  final List<MagicSpark> _sparkParticles = [];
  bool _isTyping = false;
  bool _isAITyping = false;
  String _currentAIResponse = '';
  DateTime? _lastInputTime;
  List<int> _animatedCharacters = [];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 30),
    )..addListener(_updateParticles);
    
    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateSmoke);
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    
    _controller.addListener(_onTextChanged);
    _spawnInitialParticles();
    _particleController.repeat();
    _smokeController.repeat();
  }

  void _spawnInitialParticles() {
    for (int i = 0; i < 20; i++) {
      _smokeParticles.add(SmokeParticle.random());
    }
    for (int i = 0; i < 30; i++) {
      _sparkParticles.add(MagicSpark.random());
    }
  }

  void _onTextChanged() {
    setState(() => _isTyping = _controller.text.isNotEmpty);
    _lastInputTime = DateTime.now();
    
    _addDarkMagicSparks();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (_lastInputTime != null &&
          DateTime.now().difference(_lastInputTime!) >= const Duration(seconds: 2) &&
          _controller.text.isNotEmpty &&
          !_isAITyping) {
        _triggerAIResponse();
      }
    });
  }

  void _addDarkMagicSparks() {
    for (int i = 0; i < 15; i++) {
      final spark = MagicSpark(
        x: Random().nextDouble() * MediaQuery.of(context).size.width,
        y: MediaQuery.of(context).size.height * 0.6 + Random().nextDouble() * 60 - 30,
        vx: (Random().nextDouble() - 0.5) * 2,
        vy: Random().nextDouble() * -3 - 1,
        size: Random().nextDouble() * 4 + 2,
        opacity: Random().nextDouble() * 0.8 + 0.5,
        color: Color.lerp(
          const Color(0xFF00FF41),
          const Color(0xFF39FF14),
          Random().nextDouble(),
        )!,
      );
      setState(() => _sparkParticles.add(spark));
    }
    
    for (int i = 0; i < 5; i++) {
      _smokeParticles.add(SmokeParticle(
        x: MediaQuery.of(context).size.width * 0.3 + Random().nextDouble() * MediaQuery.of(context).size.width * 0.4,
        y: MediaQuery.of(context).size.height * 0.6,
        vx: (Random().nextDouble() - 0.5) * 0.5,
        vy: -Random().nextDouble() * 0.8 - 0.3,
        size: Random().nextDouble() * 40 + 20,
        opacity: Random().nextDouble() * 0.2 + 0.1,
      ));
    }
  }

  void _updateParticles() {
    setState(() {
      for (final p in _sparkParticles) {
        p.update();
      }
      _sparkParticles.removeWhere((p) => p.opacity <= 0);
      
      if (_sparkParticles.length < 20) {
        _sparkParticles.add(MagicSpark.random());
      }
    });
  }

  void _updateSmoke() {
    setState(() {
      for (final p in _smokeParticles) {
        p.update();
      }
      _smokeParticles.removeWhere((p) => p.opacity <= 0);
      
      if (_smokeParticles.length < 15) {
        _smokeParticles.add(SmokeParticle.random());
      }
    });
  }

  Future<void> _triggerAIResponse() async {
    if (_controller.text.trim().isEmpty) return;
    
    final userText = _controller.text.trim();
    
    setState(() {
      _messages.add(Message(text: userText, isUser: true, animationKey: UniqueKey()));
      _isAITyping = true;
      _currentAIResponse = '';
      _animatedCharacters = [];
    });
    
    _controller.clear();
    
    try {
      final response = await AIService.generateMagicResponse(userText);
      _animateAIResponse(response, userText);
    } catch (e) {
      setState(() {
        _isAITyping = false;
        _messages.add(Message(
          text: "🐍 黑暗魔法已记录你的话语...",
          isUser: false,
          animationKey: UniqueKey(),
        ));
      });
    }
  }

  void _animateAIResponse(String response, String userText) async {
    for (int i = 0; i <= response.length; i++) {
      if (!mounted) break;
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _currentAIResponse = response.substring(0, i);
        if (i > 0) {
          _animatedCharacters.add(i - 1);
        }
      });
      
      if (i % 5 == 0 && mounted) {
        _addMagicRevealEffect();
      }
    }
    
    if (mounted) {
      setState(() {
        _isAITyping = false;
        _messages.add(Message(text: response, isUser: false, animationKey: UniqueKey()));
        _currentAIResponse = '';
        _animatedCharacters = [];
      });
      
      widget.onNoteSaved?.call(Note(
        question: userText,
        answer: response,
      ));
      
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _addMagicRevealEffect() {
    for (int i = 0; i < 8; i++) {
      final spark = MagicSpark(
        x: MediaQuery.of(context).size.width * 0.2 + Random().nextDouble() * MediaQuery.of(context).size.width * 0.6,
        y: MediaQuery.of(context).size.height * 0.45 + Random().nextDouble() * 50 - 25,
        vx: (Random().nextDouble() - 0.5) * 1.5,
        vy: Random().nextDouble() * -2 - 0.5,
        size: Random().nextDouble() * 3 + 1.5,
        opacity: Random().nextDouble() * 0.9 + 0.6,
        color: const Color(0xFF39FF14),
      );
      setState(() => _sparkParticles.add(spark));
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _smokeController.dispose();
    _glowController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildDarkMagicBackground(),
          
          ..._smokeParticles.map((p) => _buildSmokeParticle(p)),
          
          ..._sparkParticles.map((p) => _buildSparkParticle(p)),
          
          _buildDarkAura(),
          
          Column(
            children: [
              _buildDarkMagicHeader(),
              
              Expanded(
                child: _buildMessagesList(),
              ),
              
              if (_isAITyping) _buildDarkMagicResponse(),
              
              _buildDarkMagicInput(),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarkMagicBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF0D1A0D),
            Color(0xFF0A1510),
            Color(0xFF050A08),
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
        final glowOpacity = 0.08 + _glowController.value * 0.12;
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 400,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.8),
                radius: 1.5,
                colors: [
                  const Color(0xFF00FF41).withOpacity(glowOpacity),
                  const Color(0xFF39FF14).withOpacity(glowOpacity * 0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmokeParticle(SmokeParticle p) {
    return Positioned(
      left: p.x,
      top: p.y,
      child: Container(
        width: p.size,
        height: p.size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              const Color(0xFF1a1a1a).withOpacity(p.opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSparkParticle(MagicSpark p) {
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
              blurRadius: p.size * 4,
              spreadRadius: p.size * 0.5,
            ),
            BoxShadow(
              color: p.color.withOpacity(p.opacity * 0.5),
              blurRadius: p.size * 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkMagicHeader() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 35, bottom: 25),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      const Color(0xFF00FF41).withOpacity(0.7 + _glowController.value * 0.3),
                      const Color(0xFF39FF14),
                      const Color(0xFF00FF41).withOpacity(0.7 + _glowController.value * 0.3),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    "🐍 黑魔法笔记 🐍",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: 5,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Text(
                  _isTyping ? "黑暗力量正在苏醒..." : "在羊皮纸上写下你的咒语...",
                  style: TextStyle(
                    color: const Color(0xFF39FF14).withOpacity(0.35 + _glowController.value * 0.25),
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildMessageBubble(msg, index);
      },
    );
  }

  Widget _buildMessageBubble(Message msg, int index) {
    return TweenAnimationBuilder<double>(
      key: msg.animationKey,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!msg.isUser) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39FF14).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF39FF14).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      "🐍",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? const Color(0xFF1a1a1a).withOpacity(0.8)
                          : const Color(0xFF0D1A0D).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: msg.isUser
                            ? Colors.grey.withOpacity(0.2)
                            : const Color(0xFF39FF14).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: msg.isUser
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF39FF14).withOpacity(0.08),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser
                            ? Colors