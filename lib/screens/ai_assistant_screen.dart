import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ai_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int _currentProvider = AIService.providerGLM;

  final AIService _aiService = AIService();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        content: '''
你好！我是你的AI猜谜助手 🎯

我可以帮你：
• 生成新的谜语
• 给你猜谜提示
• 解释谜语的巧妙之处
• 解答关于谜语的问题

试试看输入你的问题吧！''',
        isUser: false,
      ));
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(content: message, isUser: true));
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    final response = await _aiService.chat(message, provider: _currentProvider);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response != null) {
          _messages.add(ChatMessage(content: response, isUser: false));
        } else {
          _messages.add(ChatMessage(
            content: '抱歉，AI服务暂时不可用，请稍后再试。',
            isUser: false,
          ));
        }
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _quickAction(String action) async {
    if (_isLoading) return;

    String prompt;
    switch (action) {
      case 'generate':
        prompt = '请给我生成一个有趣的字谜谜语';
        break;
      case 'explain':
        prompt = '请解释一下谜语"一口咬掉牛尾巴"为什么谜底是"告"';
        break;
      case 'hint':
        prompt = '给我猜谜语的小技巧';
        break;
      case 'story':
        prompt = '给我讲一个关于谜语的小故事';
        break;
      default:
        return;
    }

    _messageController.text = prompt;
    await _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI猜谜助手'),
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              setState(() {
                _currentProvider = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '已切换到${value == AIService.providerGLM ? "GLM-4-Flash" : "Moonshot"}模型'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AIService.providerGLM,
                child: Text('GLM-4-Flash'),
              ),
              const PopupMenuItem(
                value: AIService.providerMoonshot,
                child: Text('Moonshot'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActions(),
          Expanded(
            child: _buildChatList(),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionChip('生成谜语', Icons.auto_awesome, 'generate'),
            const SizedBox(width: 8),
            _buildQuickActionChip('谜语解释', Icons.psychology, 'explain'),
            const SizedBox(width: 8),
            _buildQuickActionChip('猜谜技巧', Icons.lightbulb, 'hint'),
            const SizedBox(width: 8),
            _buildQuickActionChip('谜语故事', Icons.book, 'story'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, String action) {
    return FilterChip(
      selected: false,
      onSelected: (_) => _quickAction(action),
      avatar: Icon(icon, size: 18),
      label: Text(label),
      side: BorderSide(color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message)
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.purple),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  height: 1.5,
                  color: message.isUser
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.orange),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '输入你的问题...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String content;
  final bool isUser;

  ChatMessage({required this.content, required this.isUser});
}
