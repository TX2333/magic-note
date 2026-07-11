import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/riddle_provider.dart';
import '../models/riddle.dart';
import 'riddle_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = '全部';

  final Map<String, IconData> _categoryIcons = {
    '全部': Icons.all_inclusive,
    '字谜': Icons.text_fields,
    '成语谜': Icons.format_quote,
    '动物谜': Icons.pets,
    '植物谜': Icons.eco,
    '物品谜': Icons.card_giftcard,
    '自然谜': Icons.cloud,
    '人名谜': Icons.person,
    '地名谜': Icons.location_city,
  };

  final Map<String, Color> _categoryColors = {
    '全部': Colors.blue,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('谜语分类'),
        centerTitle: true,
      ),
      body: Consumer<RiddleProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;
          final riddles = provider.getRiddlesByCategory(_selectedCategory);

          return Column(
            children: [
              _buildCategoryChips(categories),
              Expanded(
                child: _buildRiddleList(riddles),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          final color = _categoryColors[category] ?? Colors.grey;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              avatar: Icon(
                _categoryIcons[category] ?? Icons.help_outline,
                color: isSelected ? Colors.white : color,
                size: 18,
              ),
              label: Text(category),
              selectedColor: color,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
              side: BorderSide(color: color.withOpacity(0.3)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRiddleList(List<Riddle> riddles) {
    if (riddles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无谜语'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: riddles.length,
      itemBuilder: (context, index) {
        final riddle = riddles[index];
        return _buildRiddleCard(riddle, index);
      },
    );
  }

  Widget _buildRiddleCard(Riddle riddle, int index) {
    final color = _categoryColors[riddle.category] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RiddleDetailScreen(riddle: riddle),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcons[riddle.category] ?? Icons.help_outline,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riddle.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            riddle.category,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(riddle.difficulty)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            riddle.difficulty,
                            style: TextStyle(
                              color: _getDifficultyColor(riddle.difficulty),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  riddle.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  Provider.of<RiddleProvider>(context, listen: false)
                      .toggleFavorite(riddle);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '简单':
        return Colors.green;
      case '中等':
        return Colors.orange;
      case '困难':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
