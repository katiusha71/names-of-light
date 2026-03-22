import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/code_item.dart';
import '../models/combination_item.dart';

class CodesProvider extends ChangeNotifier {
  static const _customCombinationsKey = 'custom_combinations';
  static const _customIdCounterKey = 'custom_id_counter';

  List<CodeItem> _allCodes = [];
  List<CombinationItem> _builtInCombinations = [];
  List<CombinationItem> _customCombinations = [];
  String _searchQuery = '';
  String? _selectedCategory;
  final Set<int> _favoriteIds = {};
  bool _isLoading = true;
  bool _isRussian = false;
  bool _showCombinations = false;
  int _nextCustomId = 1000;

  List<CodeItem> get allCodes => _allCodes;
  List<CombinationItem> get combinations => [..._builtInCombinations, ..._customCombinations];
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  Set<int> get favoriteIds => _favoriteIds;
  bool get isRussian => _isRussian;
  bool get showCombinations => _showCombinations;

  List<String> get categories {
    if (_showCombinations) {
      final cats = combinations
          .map((c) => _isRussian ? c.categoryRu : c.category)
          .toSet()
          .toList();
      cats.sort();
      return cats;
    }
    final cats = _allCodes
        .map((c) => _isRussian ? c.categoryRu : c.category)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  List<CodeItem> get filteredCodes {
    var result = _allCodes;
    if (_selectedCategory != null) {
      result = result
          .where((c) =>
              (_isRussian ? c.categoryRu : c.category) == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((c) =>
              c.letters.contains(q) ||
              c.meaning.toLowerCase().contains(q) ||
              c.meaningRu.toLowerCase().contains(q) ||
              c.category.toLowerCase().contains(q) ||
              c.categoryRu.toLowerCase().contains(q) ||
              c.id.toString().contains(q))
          .toList();
    }
    return result;
  }

  List<CombinationItem> get filteredCombinations {
    var result = combinations;
    if (_selectedCategory != null) {
      result = result
          .where((c) =>
              (_isRussian ? c.categoryRu : c.category) == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.nameRu.toLowerCase().contains(q) ||
              c.category.toLowerCase().contains(q) ||
              c.categoryRu.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  Future<void> loadCodes() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/codes.json');
      final List<dynamic> jsonList = json.decode(jsonStr);
      _allCodes = jsonList.map((j) => CodeItem.fromJson(j)).toList();

      final combJsonStr =
          await rootBundle.loadString('assets/combinations.json');
      final List<dynamic> combJsonList = json.decode(combJsonStr);
      _builtInCombinations =
          combJsonList.map((j) => CombinationItem.fromJson(j)).toList();

      await _loadCustomCombinations();
    } catch (e) {
      debugPrint('Error loading codes: $e');
      _allCodes = [];
      _builtInCombinations = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCustomCombinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _nextCustomId = prefs.getInt(_customIdCounterKey) ?? 1000;
      final jsonStr = prefs.getString(_customCombinationsKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = json.decode(jsonStr);
        _customCombinations =
            jsonList.map((j) => CombinationItem.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Error loading custom combinations: $e');
    }
  }

  Future<void> _saveCustomCombinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(
          _customCombinations.map((c) => c.toJson()).toList());
      await prefs.setString(_customCombinationsKey, jsonStr);
      await prefs.setInt(_customIdCounterKey, _nextCustomId);
    } catch (e) {
      debugPrint('Error saving custom combinations: $e');
    }
  }

  Future<void> addCustomCombination(CombinationItem combination) async {
    final newCombo = combination.copyWith(
      id: _nextCustomId++,
      isCustom: true,
    );
    _customCombinations.add(newCombo);
    await _saveCustomCombinations();
    notifyListeners();
  }

  Future<void> updateCustomCombination(CombinationItem combination) async {
    final index = _customCombinations.indexWhere((c) => c.id == combination.id);
    if (index != -1) {
      _customCombinations[index] = combination;
      await _saveCustomCombinations();
      notifyListeners();
    }
  }

  Future<void> deleteCustomCombination(int id) async {
    _customCombinations.removeWhere((c) => c.id == id);
    await _saveCustomCombinations();
    notifyListeners();
  }

  List<CodeItem> getCodesForCombination(CombinationItem combination) {
    return combination.codeIds
        .map((id) => _allCodes.firstWhere((c) => c.id == id))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = (_selectedCategory == category) ? null : category;
    notifyListeners();
  }

  void toggleLanguage() {
    _selectedCategory = null;
    _isRussian = !_isRussian;
    notifyListeners();
  }

  void toggleFavorite(int id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  bool isFavorite(int id) => _favoriteIds.contains(id);

  void setShowCombinations(bool value) {
    _showCombinations = value;
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }
}
