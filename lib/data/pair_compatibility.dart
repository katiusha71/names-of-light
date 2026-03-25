import '../models/archetype.dart';
import 'kabbala_engine.dart';
import 'birth_profile.dart';
import 'daily_energy.dart';
import 'archetype_matrix.dart';

class PairReading {
  final int harmonyScore;
  final bool firstInitiates;
  final bool isBalanced;
  final bool firstNeedsSupport;
  final bool secondNeedsSupport;
  final int bridgeSephiraId;
  final int tensionSephiraId;
  final CompatibilityResult archetypeResult;
  final Archetype firstArchetype;
  final Archetype secondArchetype;
  final String contactAdviceEn;
  final String contactAdviceRu;

  const PairReading({
    required this.harmonyScore,
    required this.firstInitiates,
    required this.isBalanced,
    required this.firstNeedsSupport,
    required this.secondNeedsSupport,
    required this.bridgeSephiraId,
    required this.tensionSephiraId,
    required this.archetypeResult,
    required this.firstArchetype,
    required this.secondArchetype,
    required this.contactAdviceEn,
    required this.contactAdviceRu,
  });

  String getContactAdvice(bool isRu) => isRu ? contactAdviceRu : contactAdviceEn;
}

class PairCompatibility {
  /// Right pillar: Chokmah(2), Chesed(5), Netzach(8) — giving/expansive
  static const _rightPillar = [2, 5, 8];

  /// Left pillar: Binah(3), Gevurah(6), Hod(9) — receiving/contracting
  static const _leftPillar = [3, 6, 9];

  /// Sephirot to compare (exclude Daat=4 and Malkhut=11)
  static const _comparableSephirot = [1, 2, 3, 5, 6, 7, 8, 9, 10];

  /// Calculate pair compatibility from two birth dates alone.
  /// No user profile needed — both Trees are derived from birth dates + today.
  static PairReading calculate({
    required DateTime firstBirthDate,
    required DateTime secondBirthDate,
    required DateTime today,
  }) {
    // Compute both profiles and daily weights from birth dates
    final firstProfile = BirthProfile.calculateBirthProfile(firstBirthDate);
    final firstWeights = KabbalaEngine.calculateDailyWeights(
      birthDate: firstBirthDate,
      today: today,
      checkin: null,
      kwmlProfile: firstProfile,
    );

    final secondProfile = BirthProfile.calculateBirthProfile(secondBirthDate);
    final secondWeights = KabbalaEngine.calculateDailyWeights(
      birthDate: secondBirthDate,
      today: today,
      checkin: null,
      kwmlProfile: secondProfile,
    );

    // Right-pillar → who initiates
    final firstRightSum = _pillarSum(firstWeights, _rightPillar);
    final secondRightSum = _pillarSum(secondWeights, _rightPillar);
    final rightDiff = (firstRightSum - secondRightSum).abs();
    final isBalanced = rightDiff < 15.0;
    final firstInitiates = firstRightSum >= secondRightSum;

    // Left-pillar → who needs support
    final firstLeftSum = _pillarSum(firstWeights, _leftPillar);
    final secondLeftSum = _pillarSum(secondWeights, _leftPillar);
    final firstWeakestVal = _minWeight(firstWeights, _comparableSephirot);
    final secondWeakestVal = _minWeight(secondWeights, _comparableSephirot);
    final firstNeedsSupport = firstLeftSum < secondLeftSum && firstWeakestVal < 40.0;
    final secondNeedsSupport = secondLeftSum < firstLeftSum && secondWeakestVal < 40.0;

    // Bridge sephira — highest combined weight
    int bridgeSephiraId = _comparableSephirot.first;
    double maxCombined = 0;
    for (final id in _comparableSephirot) {
      final combined = (firstWeights[id] ?? 50.0) + (secondWeights[id] ?? 50.0);
      if (combined > maxCombined) {
        maxCombined = combined;
        bridgeSephiraId = id;
      }
    }

    // Tension sephira — largest difference
    int tensionSephiraId = _comparableSephirot.first;
    double maxDiff = 0;
    for (final id in _comparableSephirot) {
      final diff = ((firstWeights[id] ?? 50.0) - (secondWeights[id] ?? 50.0)).abs();
      if (diff > maxDiff) {
        maxDiff = diff;
        tensionSephiraId = id;
      }
    }

    // Archetype compatibility
    final firstKwml = KabbalaEngine.deriveKwml(firstWeights);
    final secondKwml = KabbalaEngine.deriveKwml(secondWeights);
    final firstArchetype = _topArchetype(firstKwml);
    final secondArchetype = _topArchetype(secondKwml);
    final secondVal = secondKwml[secondArchetype]!;
    final secondLevel = secondVal >= 55.0 ? ArchetypeLevel.high : ArchetypeLevel.low;
    final archetypeResult = getCompatibility(firstArchetype, secondArchetype, secondLevel);

    // Harmony score (0–100)
    final harmonyScore = _calculateHarmony(
      firstWeights: firstWeights,
      secondWeights: secondWeights,
      today: today,
    );

    // Contact advice
    final hasSharedBlindSpots = _hasSharedBlindSpots(firstWeights, secondWeights);
    final bothDepleted = firstWeakestVal < 40.0 && secondWeakestVal < 40.0;
    final tensionName = DailyEnergy.getSephiraName(tensionSephiraId);
    final tensionNameRu = DailyEnergy.getSephiraName(tensionSephiraId, isRu: true);

    String adviceEn;
    String adviceRu;
    if (harmonyScore >= 70 && !hasSharedBlindSpots) {
      adviceEn = 'Great day to connect — both trees resonate strongly.';
      adviceRu = 'Отличный день для контакта — оба дерева сильно резонируют.';
    } else if (harmonyScore >= 50) {
      adviceEn = 'Good day, but be mindful of $tensionName energy.';
      adviceRu = 'Хороший день, но будьте внимательны к энергии $tensionNameRu.';
    } else if (bothDepleted) {
      adviceEn = 'Both trees are depleted — give each other space today.';
      adviceRu = 'Оба дерева истощены — дайте друг другу пространство сегодня.';
    } else {
      adviceEn = 'Better to wait — energy alignment is low today.';
      adviceRu = 'Лучше подождать — энергетическое выравнивание сегодня низкое.';
    }

    return PairReading(
      harmonyScore: harmonyScore,
      firstInitiates: firstInitiates,
      isBalanced: isBalanced,
      firstNeedsSupport: firstNeedsSupport,
      secondNeedsSupport: secondNeedsSupport,
      bridgeSephiraId: bridgeSephiraId,
      tensionSephiraId: tensionSephiraId,
      archetypeResult: archetypeResult,
      firstArchetype: firstArchetype,
      secondArchetype: secondArchetype,
      contactAdviceEn: adviceEn,
      contactAdviceRu: adviceRu,
    );
  }

  static int _calculateHarmony({
    required Map<int, double> firstWeights,
    required Map<int, double> secondWeights,
    required DateTime today,
  }) {
    double score = 50.0;

    double complementBonus = 0;
    double blindSpotPenalty = 0;
    double amplificationBonus = 0;

    for (final id in _comparableSephirot) {
      final a = firstWeights[id] ?? 50.0;
      final b = secondWeights[id] ?? 50.0;

      if (a > 60 && b > 60) amplificationBonus += 2.0;
      if (a < 45 && b < 45) blindSpotPenalty += 3.0;
      if ((a > 60 && b < 45) || (b > 60 && a < 45)) complementBonus += 3.5;
    }

    score += complementBonus;
    score += amplificationBonus;
    score -= blindSpotPenalty;

    // Cosmic bridge bonus
    final cosmicId = DailyEnergy.weekdaySephira(today);
    final firstCosmic = firstWeights[cosmicId] ?? 50.0;
    final secondCosmic = secondWeights[cosmicId] ?? 50.0;
    if (firstCosmic > 55 && secondCosmic > 55) score += 8.0;

    // Weight similarity bonus
    double totalDiff = 0;
    for (final id in _comparableSephirot) {
      totalDiff += ((firstWeights[id] ?? 50.0) - (secondWeights[id] ?? 50.0)).abs();
    }
    final avgDiff = totalDiff / _comparableSephirot.length;
    score += (15.0 - avgDiff).clamp(-10.0, 10.0);

    return score.round().clamp(0, 100);
  }

  static double _pillarSum(Map<int, double> weights, List<int> ids) {
    double sum = 0;
    for (final id in ids) {
      sum += weights[id] ?? 50.0;
    }
    return sum;
  }

  static double _minWeight(Map<int, double> weights, List<int> ids) {
    double minVal = 100.0;
    for (final id in ids) {
      final v = weights[id] ?? 50.0;
      if (v < minVal) minVal = v;
    }
    return minVal;
  }

  static Archetype _topArchetype(Map<Archetype, double> kwml) {
    return kwml.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static bool _hasSharedBlindSpots(
    Map<int, double> firstWeights,
    Map<int, double> secondWeights,
  ) {
    for (final id in _comparableSephirot) {
      final a = firstWeights[id] ?? 50.0;
      final b = secondWeights[id] ?? 50.0;
      if (a < 42 && b < 42) return true;
    }
    return false;
  }
}
