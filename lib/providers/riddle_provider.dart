import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
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

    // 从本地文件加载收藏
    await _loadFavorites();

    _isLoading = false;
    notifyListeners();
  }

  Future<File> _getFavoritesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/favorites.json');
  }

  Future<void> _loadFavorites() async {
    try {
      final file = await _getFavoritesFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> decoded = json.decode(contents);
        final favoriteIds = decoded.cast<String>();
        
        // 标记收藏的谜语
        for (var riddle in _riddles) {
          if (favoriteIds.contains(riddle.id)) {
            riddle.isFavorite = true;
          }
        }
        
        _favorites = _riddles.where((r) => r.isFavorite).toList();
      }
    } catch (e) {
      // 忽略错误，使用空收藏列表
      _favorites = [];
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final file = await _getFavoritesFile();
      final favoriteIds = _favorites.map((r) => r.id).toList();
      await file.writeAsString(json.encode(favoriteIds));
    } catch (e) {
      // 忽略保存错误
    }
  }

  void toggleFavorite(Riddle riddle) {
    riddle.isFavorite = !riddle.isFavorite;
    
    if (riddle.isFavorite) {
      _favorites.add(riddle);
    } else {
      _favorites.removeWhere((r) => r.id == riddle.id);
    }
    
    _saveFavorites();
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
