import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/code_item.dart';
import '../models/combination_item.dart';
import '../models/sephira_item.dart';
import '../models/archetype.dart';
import '../models/user_profile.dart';
import '../data/archetype_matrix.dart';
import '../data/kabbala_engine.dart';
import '../data/patterns_data.dart';
import '../data/prescriptions_data.dart';
import '../data/daily_energy.dart';
import '../data/daily_checkin.dart';
import '../data/birth_profile.dart';
import '../data/pair_compatibility.dart';
import '../models/code_item.dart' show CodeItem;

enum DashboardSection { codes, combinations, tree, pair, archetype }

class CodesProvider extends ChangeNotifier {
  static const _customCombinationsKey = 'custom_combinations';
  static const _customIdCounterKey = 'custom_id_counter';
  static const _profileKey = 'user_profile';
  static const _questionnaireCompletedKey = 'questionnaire_completed';
  static const _aiApiKeyKey = 'ai_api_key';
  static const _birthDateKey = 'birth_date';
  static const _pairDate1Key = 'pair_date_1';
  static const _pairDate2Key = 'pair_date_2';

  List<CodeItem> _allCodes = [];
  List<CombinationItem> _builtInCombinations = [];
  List<CombinationItem> _customCombinations = [];
  String _searchQuery = '';
  String? _selectedCategory;
  final Set<int> _favoriteIds = {};
  bool _isLoading = true;
  bool _isRussian = false;
  DashboardSection _activeSection = DashboardSection.codes;
  int _nextCustomId = 1000;

  // Tree of Life state
  List<SephiraItem> _sephirot = [];
  Map<int, double> _sephiraWeights = {};
  bool _showDaat = true;

  // Profile & diagnostic state
  UserProfile _profile = UserProfile.empty();
  List<ActivePattern> _activePatterns = [];
  List<Prescription> _prescriptions = [];
  SephiraItem? _dominant;
  SephiraItem? _weakest;
  bool _hasCompletedQuestionnaire = false;
  String? _aiApiKey;

  // Birth date & daily system
  DateTime? _birthDate;
  DailyCheckin? _todayCheckin;
  CosmicSummary? _cosmicSummary;
  BirthProfileSummary? _birthProfileSummary;
  CodeItem? _dailyAnchorCode;

  // Pair compatibility (two independent birth dates)
  DateTime? _pairDate1;
  DateTime? _pairDate2;
  PairReading? _pairReading;

  List<CodeItem> get allCodes => _allCodes;
  List<CombinationItem> get combinations => [..._builtInCombinations, ..._customCombinations];
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  Set<int> get favoriteIds => _favoriteIds;
  bool get isRussian => _isRussian;
  DashboardSection get activeSection => _activeSection;
  bool get showCombinations => _activeSection == DashboardSection.combinations;

  // Tree of Life getters
  List<SephiraItem> get sephirot => _sephirot;
  List<SephiraItem> get visibleSephirot =>
      _showDaat ? _sephirot : _sephirot.where((s) => !s.isHidden).toList();
  Map<int, double> get sephiraWeights => _sephiraWeights;
  bool get showDaat => _showDaat;

  // Profile & diagnostic getters
  UserProfile get profile => _profile;
  List<ActivePattern> get activePatterns => _activePatterns;
  List<Prescription> get prescriptions => _prescriptions;
  SephiraItem? get dominant => _dominant;
  SephiraItem? get weakest => _weakest;
  bool get hasCompletedQuestionnaire => _hasCompletedQuestionnaire;
  String? get aiApiKey => _aiApiKey;

  // Derived KWML/Pillars from current sephira weights (live, change daily)
  Map<Archetype, double> get derivedKwml =>
      KabbalaEngine.deriveKwml(_sephiraWeights);
  Map<Pillar, double> get derivedPillars =>
      KabbalaEngine.derivePillars(_sephiraWeights);

  // Birth date & daily system getters
  DateTime? get birthDate => _birthDate;
  DailyCheckin? get todayCheckin => _todayCheckin;
  CosmicSummary? get cosmicSummary => _cosmicSummary;
  BirthProfileSummary? get birthProfileSummary => _birthProfileSummary;
  bool get hasCheckedInToday => _todayCheckin != null && _todayCheckin!.isToday;
  bool get hasBirthDate => _birthDate != null;
  CodeItem? get dailyAnchorCode => _dailyAnchorCode;

  // Pair compatibility getters
  DateTime? get pairDate1 => _pairDate1;
  DateTime? get pairDate2 => _pairDate2;
  PairReading? get pairReading => _pairReading;

  double getSephiraWeight(int id) => _sephiraWeights[id] ?? 50.0;

  List<String> get categories {
    if (_activeSection == DashboardSection.combinations) {
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
      await _loadSephirot();
      await _loadProfile();
      await _loadBirthDate();
      await _loadDailyCheckin();
      await _loadPairDates();
      _updateCosmicSummary();
      recalculate();
    } catch (e) {
      debugPrint('Error loading codes: $e');
      _allCodes = [];
      _builtInCombinations = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSephirot() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/sephirot.json');
      final List<dynamic> jsonList = json.decode(jsonStr);
      _sephirot = jsonList.map((j) => SephiraItem.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error loading sephirot: $e');
      _sephirot = [];
    }
  }


  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedQuestionnaire =
          prefs.getBool(_questionnaireCompletedKey) ?? false;
      _aiApiKey = prefs.getString(_aiApiKeyKey);

      final profileStr = prefs.getString(_profileKey);
      if (profileStr != null) {
        _profile = UserProfile.decode(profileStr);
        recalculate();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, _profile.encode());
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  Future<void> _loadBirthDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_birthDateKey);
      if (str != null) {
        _birthDate = DateTime.tryParse(str);
        _updateBirthProfileSummary();

        // If profile is at defaults and we have a birth date, derive from it
        if (_birthDate != null && !_hasCompletedQuestionnaire) {
          final isDefault = _profile.kwml.values.every((v) => v == 50.0) &&
              _profile.pillars.values.every((v) => v == 50.0);
          if (isDefault) {
            _profile = BirthProfile.calculateBirthProfile(_birthDate!);
            _saveProfile();
            recalculate();
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading birth date: $e');
    }
  }

  Future<void> _saveBirthDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_birthDate != null) {
        await prefs.setString(_birthDateKey, _birthDate!.toIso8601String());
      } else {
        await prefs.remove(_birthDateKey);
      }
    } catch (e) {
      debugPrint('Error saving birth date: $e');
    }
  }

  Future<void> _loadDailyCheckin() async {
    _todayCheckin = await DailyCheckin.load();
  }

  void _updateCosmicSummary() {
    _cosmicSummary = DailyEnergy.getCosmicSummary(
      DateTime.now(),
      isRu: _isRussian,
    );
  }

  void _updateBirthProfileSummary() {
    if (_birthDate != null) {
      _birthProfileSummary = BirthProfile.getSummary(
        _birthDate!,
        isRu: _isRussian,
      );
    } else {
      _birthProfileSummary = null;
    }
  }

  void setBirthDate(DateTime? date) {
    _birthDate = date;
    _saveBirthDate();
    _updateBirthProfileSummary();

    // Derive KWML/Pillar profile from birth date
    // (unless user has completed the questionnaire — those are manual overrides)
    if (date != null && !_hasCompletedQuestionnaire) {
      _profile = BirthProfile.calculateBirthProfile(date);
      _saveProfile();
    }

    recalculate();
    notifyListeners();
  }

  void setDailyCheckin(DailyCheckin checkin) {
    _todayCheckin = checkin;
    DailyCheckin.save(checkin);
    recalculate();
    notifyListeners();
  }

  void setKwmlScore(Archetype archetype, double value) {
    _profile.kwml[archetype] = value.clamp(0.0, 100.0);
    _saveProfile();
    recalculate();
    notifyListeners();
  }

  void setPillarScore(Pillar pillar, double value) {
    _profile.pillars[pillar] = value.clamp(0.0, 100.0);
    _saveProfile();
    recalculate();
    notifyListeners();
  }

  void setProfile(UserProfile profile) {
    _profile = profile;
    _saveProfile();
    recalculate();
    notifyListeners();
  }

  void setQuestionnaireCompleted(bool value) {
    _hasCompletedQuestionnaire = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_questionnaireCompletedKey, value);
    });
    notifyListeners();
  }

  void setAiApiKey(String? key) {
    _aiApiKey = key;
    SharedPreferences.getInstance().then((prefs) {
      if (key != null && key.isNotEmpty) {
        prefs.setString(_aiApiKeyKey, key);
      } else {
        prefs.remove(_aiApiKeyKey);
      }
    });
    notifyListeners();
  }

  void setPrescriptions(List<Prescription> prescriptions) {
    _prescriptions = prescriptions;
    notifyListeners();
  }

  /// Run the Kabbala engine: recalculate weights, patterns, prescriptions
  void recalculate() {
    _updateCosmicSummary();

    // Calculate sephira weights using additive formula
    _sephiraWeights = KabbalaEngine.calculateDailyWeights(
      birthDate: _birthDate,
      today: DateTime.now(),
      checkin: _todayCheckin,
      kwmlProfile: _profile,
    );

    // Find dominant & weakest
    final (dom, weak) = KabbalaEngine.findDominantWeakest(_sephiraWeights, _sephirot);
    _dominant = dom;
    _weakest = weak;

    // Detect patterns
    _activePatterns = KabbalaEngine.detectPatterns(_profile);

    // Pick today's anchor code (personalized via dominant sephira)
    _dailyAnchorCode = KabbalaEngine.pickDailyAnchorCode(
      date: DateTime.now(),
      allCodes: _allCodes,
      sephirot: _sephirot,
      dominantSephira: _dominant,
    );

    // Recalculate pair compatibility if partner date is set
    _calculatePairReading();

    // Generate daily prescriptions (offline)
    _prescriptions = KabbalaEngine.generatePrescriptions(
      dominant: _dominant,
      weakest: _weakest,
      patterns: _activePatterns,
      date: DateTime.now(),
      cosmicSummary: _cosmicSummary,
      checkin: _todayCheckin,
      anchorCode: _dailyAnchorCode,
      derivedKwml: derivedKwml,
    );
  }

  void setSephiraWeight(int id, double weight) {
    _sephiraWeights[id] = weight;
    notifyListeners();
  }

  void toggleDaat() {
    _showDaat = !_showDaat;
    notifyListeners();
  }

  List<CodeItem> getCodesForSephira(int sephiraId) {
    final sephira = _sephirot.firstWhere((s) => s.id == sephiraId,
        orElse: () => _sephirot.first);
    return sephira.associated72NameIds
        .where((id) => id >= 1 && id <= _allCodes.length)
        .map((id) => _allCodes.firstWhere((c) => c.id == id))
        .toList();
  }

  CompatibilityResult getCompatibilityInsights(
    Archetype userArchetype,
    Archetype partnerArchetype,
    ArchetypeLevel partnerLevel,
  ) {
    return getCompatibility(userArchetype, partnerArchetype, partnerLevel);
  }

  CodeItem? getCodeById(int id) {
    try {
      return _allCodes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  SephiraItem? getSephiraById(int id) {
    try {
      return _sephirot.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
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

  Future<void> _loadPairDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s1 = prefs.getString(_pairDate1Key);
      final s2 = prefs.getString(_pairDate2Key);
      if (s1 != null) _pairDate1 = DateTime.tryParse(s1);
      if (s2 != null) _pairDate2 = DateTime.tryParse(s2);
      _calculatePairReading();
    } catch (e) {
      debugPrint('Error loading pair dates: $e');
    }
  }

  Future<void> _savePairDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_pairDate1 != null) {
        await prefs.setString(_pairDate1Key, _pairDate1!.toIso8601String());
      } else {
        await prefs.remove(_pairDate1Key);
      }
      if (_pairDate2 != null) {
        await prefs.setString(_pairDate2Key, _pairDate2!.toIso8601String());
      } else {
        await prefs.remove(_pairDate2Key);
      }
    } catch (e) {
      debugPrint('Error saving pair dates: $e');
    }
  }

  void setPairDate1(DateTime? date) {
    _pairDate1 = date;
    _savePairDates();
    _calculatePairReading();
    notifyListeners();
  }

  void setPairDate2(DateTime? date) {
    _pairDate2 = date;
    _savePairDates();
    _calculatePairReading();
    notifyListeners();
  }

  void clearPairDates() {
    _pairDate1 = null;
    _pairDate2 = null;
    _pairReading = null;
    _savePairDates();
    notifyListeners();
  }

  void _calculatePairReading() {
    if (_pairDate1 == null || _pairDate2 == null) {
      _pairReading = null;
      return;
    }
    _pairReading = PairCompatibility.calculate(
      firstBirthDate: _pairDate1!,
      secondBirthDate: _pairDate2!,
      today: DateTime.now(),
    );
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
    _updateCosmicSummary();
    _updateBirthProfileSummary();
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
    _activeSection = value ? DashboardSection.combinations : DashboardSection.codes;
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  void setActiveSection(DashboardSection section) {
    _activeSection = section;
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }
}
