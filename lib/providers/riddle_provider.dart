import 'package:flutter/material.dart';
import '../models/riddle.dart';
import '../data/riddle_data.dart';

class RiddleProvider with ChangeNotifier {
  List<Riddle> _riddles = [];
  List<Riddle> _favorites = [];
  bool _isLoading = true;

  List<Riddle> get riddles => _riddles;
  List<Riddle> get favorites => _favorites;
  bool get isLoading => _isLoading;

  RiddleProvider() {
    _loadRiddles();
  }

  Future<void> _loadRiddles() async {
    _isLoading = true;
    notifyListeners();

    // 加载内置谜语数据
    _riddles = RiddleData.getAllRiddles();

    // 注意：收藏只存在内存中，App 重启后会丢失
    // （这是为了避免 Flutter Gradle 插件 Bug 而做的妥协）
    _favorites = [];

    _isLoading = false;
    notifyListeners();
  }

  void toggleFavorite(Riddle riddle) {
    riddle.isFavorite = !riddle.isFavorite;
    
    if (riddle.isFavorite) {
      _favorites.add(riddle);
    } else {
      _favorites.removeWhere((r) => r.id == riddle.id);
    }
    
    notifyListeners();
  }

  List<Riddle> getRiddlesByCategory(String category) {
    if (category == '全部') return _riddles;
    return _riddles.where((r) => r.category == category).toList();
  }

  Riddle getRandomRiddle({String? category}) {
    List<Riddle> pool = category != null 
        ? getRiddlesByCategory(category) 
        : _riddles;
    
    if (pool.isEmpty) pool = _riddles;
    
    pool.shuffle();
    return pool.first;
  }

  List<Riddle> searchRiddles(String query) {
    if (query.isEmpty) return [];
    query = query.toLowerCase();
    return _riddles.where((r) {
      return r.question.toLowerCase().contains(query) ||
             r.answer.toLowerCase().contains(query);
    }).toList();
  }

  List<String> get categories {
    final set = Set<String>.from(_riddles.map((r) => r.category));
    return ['全部', ...set.toList()];
  }
}
