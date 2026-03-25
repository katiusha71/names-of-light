import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/archetype.dart';
import '../models/user_profile.dart';
import '../models/sephira_item.dart';
import '../data/patterns_data.dart';
import '../data/prescriptions_data.dart';

class AIPrescriptionService {
  static const _cacheKey = 'ai_prescriptions_cache';
  static const _cacheDateKey = 'ai_prescriptions_date';

  /// Check if we have cached AI prescriptions for today
  static Future<List<Prescription>?> getCachedPrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDate = prefs.getString(_cacheDateKey);
      final today = _todayKey();
      if (cachedDate != today) return null;

      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr == null) return null;

      final List<dynamic> list = json.decode(jsonStr);
      return list.map((j) => Prescription.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error reading AI prescription cache: $e');
      return null;
    }
  }

  /// Cache prescriptions for today
  static Future<void> cachePrescriptions(List<Prescription> prescriptions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheDateKey, _todayKey());
      await prefs.setString(
        _cacheKey,
        json.encode(prescriptions.map((p) => p.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error caching AI prescriptions: $e');
    }
  }

  /// Build the prompt for the AI API
  static String buildPrompt({
    required UserProfile profile,
    required SephiraItem? dominant,
    required SephiraItem? weakest,
    required List<ActivePattern> patterns,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('You are a Kabbalistic advisor. Based on the following profile, generate exactly 3 personalized daily prescriptions.');
    buffer.writeln('Each prescription should be 1-2 sentences, practical and actionable.');
    buffer.writeln('');
    buffer.writeln('KWML Scores:');
    for (final e in profile.kwml.entries) {
      buffer.writeln('  ${e.key.nameEn}: ${e.value.round()}');
    }
    buffer.writeln('');
    buffer.writeln('Pillar Scores (Sphinx Powers):');
    for (final e in profile.pillars.entries) {
      buffer.writeln('  ${e.key.nameEn} (${e.key.latinName}): ${e.value.round()}');
    }
    buffer.writeln('');
    if (dominant != null) {
      buffer.writeln('Dominant Sephira: ${dominant.nameEnglish} (${dominant.nameHebrew})');
    }
    if (weakest != null) {
      buffer.writeln('Weakest Sephira: ${weakest.nameEnglish} (${weakest.nameHebrew})');
    }
    if (patterns.isNotEmpty) {
      buffer.writeln('Active Patterns: ${patterns.map((p) => p.nameEn).join(', ')}');
    }
    buffer.writeln('');
    buffer.writeln('Respond in JSON format: [{"textEn": "...", "textRu": "..."}]');
    buffer.writeln('Provide both English and Russian text for each prescription.');
    return buffer.toString();
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
