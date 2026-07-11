import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/riddle_provider.dart';
import '../models/riddle.dart';

class RiddleDetailScreen extends StatefulWidget {
  final Riddle riddle;

  const RiddleDetailScreen({super.key, required this.riddle});

  @override
  State<RiddleDetailScreen> createState() => _RiddleDetailScreenState();
}

class _RiddleDetailScreenState extends State<RiddleDetailScreen> {
  bool _showAnswer = false;

  final Map<String, Color> _categoryColors = {
    '字谜': Colors.purple,
    '成语谜': Colors.orange,
    '动物谜': Colors.brown,
    '植物谜': Colors.green,
    '物品谜': Colors.teal,
    '自然谜': Colors.lightBlue,
    '人名谜': Colors.pink,
    '地名谜': Colors.amber,
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[widget.riddle.category] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.riddle.category),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              widget.riddle.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              Provider.of<RiddleProvider>(context, listen: false)
                  .toggleFavorite(widget.riddle);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDifficultyBadge(),
            const SizedBox(height: 30),
            _buildQuestionCard(color),
            const SizedBox(height: 30),
            _buildAnswerSection(color),
            if (widget.riddle.hint != null) ...[
              const SizedBox(height: 20),
              _buildHintCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    Color color;
    switch (widget.riddle.difficulty) {
      case '简单':
        color = Colors.green;
        break;
      case '中等':
        color = Colors.orange;
        break;
      case '困难':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          '难度：${widget.riddle.difficulty}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.05),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              Icons.question_mark,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            const Text(
              '谜面',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.riddle.question,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildAnswerSection(Color color) {
    return Column(
      children: [
        if (!_showAnswer)
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _showAnswer = true;
              });
            },
            icon: const Icon(Icons.visibility),
            label: const Text('揭晓答案'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        if (_showAnswer)
          Card(
            elevation: 4,
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '谜底',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.riddle.answer,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
      ],
    );
  }

  Widget _buildHintCard() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '小提示',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.riddle.hint!,
                    style: TextStyle(
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
