import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

    // 从本地存储加载收藏
    await _loadFavorites();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      final List<dynamic> decoded = json.decode(favoritesJson);
      final favoriteIds = decoded.cast<String>();
      
      // 标记收藏的谜语
      for (var riddle in _riddles) {
        if (favoriteIds.contains(riddle.id)) {
          riddle.isFavorite = true;
        }
      }
      
      _favorites = _riddles.where((r) => r.isFavorite).toList();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = _favorites.map((r) => r.id).toList();
    await prefs.setString('favorites', json.encode(favoriteIds));
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
