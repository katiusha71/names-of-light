import 'dart:math';
import '../models/archetype.dart';
import '../models/user_profile.dart';
import '../models/sephira_item.dart';
import '../models/code_item.dart';
import 'patterns_data.dart';
import 'prescriptions_data.dart';
import 'birth_profile.dart';
import 'daily_energy.dart';
import 'daily_checkin.dart';

class KabbalaEngine {
  /// Sephira IDs:
  /// 1=Keter, 2=Chokmah, 3=Binah, 4=Daat, 5=Chesed,
  /// 6=Gevurah, 7=Tiferet, 8=Netzach, 9=Hod, 10=Yesod, 11=Malkhut

  /// Legacy: calculate weights from KWML/Pillar profile only (used as fallback)
  static Map<int, double> calculateSephiraWeights(UserProfile profile) {
    final kwml = profile.kwml;
    final pillars = profile.pillars;
    final weights = <int, double>{};

    // Initialize all to 0
    for (int i = 1; i <= 11; i++) {
      weights[i] = 0.0;
    }

    // Contribution counters for averaging
    final counts = <int, int>{for (int i = 1; i <= 11; i++) i: 0};

    void addContribution(int sephiraId, double value, double factor) {
      weights[sephiraId] = weights[sephiraId]! + value * factor;
      counts[sephiraId] = counts[sephiraId]! + 1;
    }

    // KWML -> Sephira mapping (primary 0.7, secondary 0.3)
    addContribution(1, kwml[Archetype.king]!, 0.7);
    addContribution(7, kwml[Archetype.king]!, 0.3);
    addContribution(6, kwml[Archetype.warrior]!, 0.7);
    addContribution(8, kwml[Archetype.warrior]!, 0.3);
    addContribution(2, kwml[Archetype.magician]!, 0.7);
    addContribution(3, kwml[Archetype.magician]!, 0.7);
    addContribution(9, kwml[Archetype.magician]!, 0.3);
    addContribution(5, kwml[Archetype.lover]!, 0.7);
    addContribution(10, kwml[Archetype.lover]!, 0.3);

    // Pillars -> Sephira mapping
    addContribution(2, pillars[Pillar.know]!, 0.7);
    addContribution(4, pillars[Pillar.know]!, 0.3);
    addContribution(6, pillars[Pillar.dare]!, 0.7);
    addContribution(8, pillars[Pillar.dare]!, 0.3);
    addContribution(1, pillars[Pillar.will]!, 0.7);
    addContribution(7, pillars[Pillar.will]!, 0.3);
    addContribution(3, pillars[Pillar.silent]!, 0.7);
    addContribution(10, pillars[Pillar.silent]!, 0.3);

    // Average each sephira by contribution count
    for (int i = 1; i <= 11; i++) {
      if (counts[i]! > 0) {
        weights[i] = (weights[i]! / counts[i]!).clamp(0.0, 100.0);
      }
    }

    // Malkhut(11) = average of all scores (grounding)
    final allScores = [
      ...kwml.values,
      ...pillars.values,
    ];
    weights[11] = allScores.reduce((a, b) => a + b) / allScores.length;

    return weights;
  }

  /// Additive daily weights formula:
  ///   base(50) + personalBonuses + cosmicBonuses + kwmlModifier + checkinAdjust
  ///
  /// Personal bonuses: birth month primary +20, life path +15, weekday +8, etc.
  /// Cosmic bonuses: weekday +8, month +4, omer +6/+3
  /// KWML modifier: small deviation-based adjustment (±3)
  /// Check-in: maps 0-100 input to ±12 range
  ///
  /// Result range: ~35-85
  static Map<int, double> calculateDailyWeights({
    required DateTime? birthDate,
    required DateTime today,
    DailyCheckin? checkin,
    required UserProfile kwmlProfile,
  }) {
    // Start with personal baseline (base 50 + birth bonuses)
    // or flat 50 if no birth date
    final weights = <int, double>{};
    if (birthDate != null) {
      final baseline = BirthProfile.calculatePersonalBaseline(birthDate);
      for (int i = 1; i <= 11; i++) {
        weights[i] = baseline[i]!;
      }
    } else {
      for (int i = 1; i <= 11; i++) {
        weights[i] = 50.0;
      }
    }

    // Add cosmic bonuses (deviation from cosmic base of 50)
    final cosmic = DailyEnergy.calculateDailyCosmicWeights(today);
    for (int i = 1; i <= 11; i++) {
      weights[i] = weights[i]! + (cosmic[i]! - 50.0);
    }

    // Add small KWML modifier (deviation from average)
    final kwmlWeights = calculateSephiraWeights(kwmlProfile);
    double kwmlAvg = 0;
    for (int i = 1; i <= 11; i++) {
      kwmlAvg += kwmlWeights[i] ?? 50.0;
    }
    kwmlAvg /= 11;
    for (int i = 1; i <= 11; i++) {
      final deviation = (kwmlWeights[i] ?? kwmlAvg) - kwmlAvg;
      weights[i] = weights[i]! + deviation * 0.05;
    }

    // Add check-in adjustment (deviation from neutral 50)
    final checkinAdj = DailyCheckin.checkinToSephiraAdjustments(checkin);
    for (int i = 1; i <= 11; i++) {
      final adj = (checkinAdj[i]! - 50.0) * 0.25;
      weights[i] = weights[i]! + adj;
    }

    // Clamp all weights
    for (int i = 1; i <= 11; i++) {
      weights[i] = weights[i]!.clamp(5.0, 95.0);
    }

    return weights;
  }

  /// Reverse mapping: derive KWML display values from sephira weights.
  /// Each archetype reads from its associated sephirot.
  static Map<Archetype, double> deriveKwml(Map<int, double> w) {
    double s(int id) => w[id] ?? 50.0;
    return {
      // King ← Keter(1), Tiferet(7)
      Archetype.king: (s(1) * 0.6 + s(7) * 0.4).clamp(0, 100),
      // Warrior ← Gevurah(6), Netzach(8)
      Archetype.warrior: (s(6) * 0.6 + s(8) * 0.4).clamp(0, 100),
      // Magician ← Chokmah(2), Binah(3), Hod(9)
      Archetype.magician: (s(2) * 0.35 + s(3) * 0.35 + s(9) * 0.3).clamp(0, 100),
      // Lover ← Chesed(5), Yesod(10)
      Archetype.lover: (s(5) * 0.6 + s(10) * 0.4).clamp(0, 100),
    };
  }

  /// Reverse mapping: derive Pillar display values from sephira weights.
  static Map<Pillar, double> derivePillars(Map<int, double> w) {
    double s(int id) => w[id] ?? 50.0;
    return {
      // Know ← Chokmah(2), Hod(9), Daat(4)
      Pillar.know: (s(2) * 0.4 + s(9) * 0.35 + s(4) * 0.25).clamp(0, 100),
      // Dare ← Gevurah(6), Netzach(8), Chesed(5)
      Pillar.dare: (s(6) * 0.4 + s(8) * 0.35 + s(5) * 0.25).clamp(0, 100),
      // Will ← Keter(1), Tiferet(7), Malkhut(11)
      Pillar.will: (s(1) * 0.45 + s(7) * 0.35 + s(11) * 0.20).clamp(0, 100),
      // Silent ← Binah(3), Yesod(10)
      Pillar.silent: (s(3) * 0.6 + s(10) * 0.4).clamp(0, 100),
    };
  }

  static (SephiraItem?, SephiraItem?) findDominantWeakest(
    Map<int, double> weights,
    List<SephiraItem> sephirot,
  ) {
    if (sephirot.isEmpty || weights.isEmpty) return (null, null);

    // Exclude Daat(4) and Malkhut(11) from dominant/weakest
    final candidates =
        sephirot.where((s) => s.id != 4 && s.id != 11 && !s.isHidden).toList();
    if (candidates.isEmpty) return (null, null);

    SephiraItem dominant = candidates.first;
    SephiraItem weakest = candidates.first;

    for (final s in candidates) {
      final w = weights[s.id] ?? 50.0;
      if (w > (weights[dominant.id] ?? 50.0)) dominant = s;
      if (w < (weights[weakest.id] ?? 50.0)) weakest = s;
    }

    return (dominant, weakest);
  }

  static List<ActivePattern> detectPatterns(UserProfile profile) {
    return allPatterns
        .where((p) => p.condition(profile.kwml, profile.pillars))
        .toList();
  }

  /// Pick today's anchor code from the 72 Names.
  /// If a dominant sephira is provided, picks from its codes (personalized).
  /// Otherwise falls back to the cosmic weekday sephira (same for everyone).
  static CodeItem? pickDailyAnchorCode({
    required DateTime date,
    required List<CodeItem> allCodes,
    required List<SephiraItem> sephirot,
    SephiraItem? dominantSephira,
  }) {
    if (allCodes.isEmpty || sephirot.isEmpty) return null;

    // Try dominant sephira first for personalized selection
    SephiraItem? sephira;
    int seedExtra = 0;
    if (dominantSephira != null &&
        dominantSephira.associated72NameIds.isNotEmpty) {
      sephira = dominantSephira;
      seedExtra = dominantSephira.id * 7; // mix dominant id into seed
    }

    // Fallback to cosmic weekday sephira
    if (sephira == null) {
      final weekdaySephiraId = DailyEnergy.weekdaySephira(date);
      sephira = sephirot.cast<SephiraItem?>().firstWhere(
            (s) => s!.id == weekdaySephiraId,
            orElse: () => null,
          );
    }
    if (sephira == null) return null;

    final codeIds = sephira.associated72NameIds;
    if (codeIds.isEmpty) return null;

    // Deterministic pick based on date + dominant id (so same code all day)
    final seed =
        date.year * 10000 + date.month * 100 + date.day + seedExtra;
    final rng = Random(seed);
    final codeId = codeIds[rng.nextInt(codeIds.length)];

    try {
      return allCodes.firstWhere((c) => c.id == codeId);
    } catch (_) {
      return null;
    }
  }

  /// Generate 3 daily prescriptions:
  /// 1. Personal dominant sephira (most individual)
  /// 2. Anchor — a specific 72 Name code (personalized via dominant sephira)
  /// 3. Personal weakest sephira + check-in state
  static List<Prescription> generatePrescriptions({
    required SephiraItem? dominant,
    required SephiraItem? weakest,
    required List<ActivePattern> patterns,
    required DateTime date,
    CosmicSummary? cosmicSummary,
    DailyCheckin? checkin,
    CodeItem? anchorCode,
    Map<Archetype, double>? derivedKwml,
  }) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final rng = Random(seed);
    final result = <Prescription>[];

    // 1. Personal dominant sephira prescription (most individual)
    //    Priority: dominant_[id] > pattern > archetype > dominant_generic
    if (dominant != null) {
      final domPool = prescriptionTemplates
          .where((p) => p.trigger == 'dominant_${dominant.id}')
          .toList();
      if (domPool.isNotEmpty) {
        result.add(domPool[rng.nextInt(domPool.length)]);
      }
    }
    if (result.isEmpty && patterns.isNotEmpty) {
      final patternPool = prescriptionTemplates
          .where((p) => patterns.any((pat) => p.trigger == 'pattern_${pat.id}'))
          .toList();
      if (patternPool.isNotEmpty) {
        result.add(patternPool[rng.nextInt(patternPool.length)]);
      }
    }
    if (result.isEmpty && derivedKwml != null) {
      final topArchetype = derivedKwml.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      final pool = prescriptionTemplates
          .where((p) => p.trigger == 'archetype_${topArchetype.name}')
          .toList();
      if (pool.isNotEmpty) {
        result.add(pool[rng.nextInt(pool.length)]);
      }
    }
    if (result.isEmpty) {
      final generic = prescriptionTemplates
          .where((p) => p.trigger == 'dominant_generic')
          .toList();
      if (generic.isNotEmpty) {
        result.add(generic[rng.nextInt(generic.length)]);
      }
    }

    // 2. Anchor prescription — today's 72 Name code with codeItem for navigation
    if (anchorCode != null) {
      final domName = dominant?.getName(false) ?? '';
      final domNameRu = dominant?.getName(true) ?? '';
      final sephiraQualityEn = cosmicSummary != null
          ? '${cosmicSummary.weekdaySephiraName} = ${_sephiraQualityEn(cosmicSummary.weekdaySephiraId)}'
          : '';
      final sephiraQualityRu = cosmicSummary != null
          ? '${cosmicSummary.weekdaySephiraName} = ${_sephiraQualityRu(cosmicSummary.weekdaySephiraId)}'
          : '';
      final personalEn = domName.isNotEmpty ? ' Through your $domName lens,' : '';
      final personalRu = domNameRu.isNotEmpty ? ' Через призму $domNameRu,' : '';
      result.add(Prescription(
        textEn: 'Your anchor today is "${anchorCode.letters} ${anchorCode.meaning}"'
            ' — meditate on this code.$personalEn $sephiraQualityEn.',
        textRu: 'Твой якорь сегодня — "${anchorCode.letters} ${anchorCode.meaningRu}"'
            ' — медитируй на этот код.$personalRu $sephiraQualityRu.',
        trigger: 'anchor',
        codeItem: anchorCode,
      ));
    } else if (cosmicSummary != null) {
      final cosmicPool = prescriptionTemplates
          .where((p) => p.trigger == 'cosmic_weekday_${cosmicSummary.weekdaySephiraId}')
          .toList();
      if (cosmicPool.isNotEmpty) {
        result.add(cosmicPool[rng.nextInt(cosmicPool.length)]);
      }
    }

    // 3. Personal weakest sephira + check-in state
    if (weakest != null) {
      final weakPool = prescriptionTemplates
          .where((p) => p.trigger == 'weakest_${weakest.id}')
          .toList();
      if (weakPool.isNotEmpty) {
        result.add(weakPool[rng.nextInt(weakPool.length)]);
      } else {
        final generic = prescriptionTemplates
            .where((p) => p.trigger == 'weakest_generic')
            .toList();
        if (generic.isNotEmpty) {
          result.add(generic[rng.nextInt(generic.length)]);
        }
      }
    }
    // If check-in has extreme values, replace or supplement #3
    if (checkin != null && result.length >= 2) {
      final scores = {
        'energy': checkin.energy,
        'clarity': checkin.clarity,
        'heart': checkin.heart,
        'sleep': checkin.sleep,
      };
      final worst = scores.entries.reduce((a, b) => a.value < b.value ? a : b);
      final best = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (worst.value < 35 || best.value > 65) {
        // If we already have 3 prescriptions, replace #3; otherwise add
        final checkinRx = _checkinPrescription(checkin);
        if (result.length >= 3) {
          result[2] = checkinRx;
        } else {
          result.add(checkinRx);
        }
      }
    }

    // Fill up to 3 from general pool if needed
    if (result.length < 3) {
      final general = prescriptionTemplates
          .where((p) => p.trigger == 'general')
          .toList();
      general.shuffle(rng);
      for (final g in general) {
        if (result.length >= 3) break;
        if (!result.any((r) => r.textEn == g.textEn)) {
          result.add(g);
        }
      }
    }

    return result.take(3).toList();
  }

  /// Generate a prescription based on the strongest check-in parameter.
  static Prescription _checkinPrescription(DailyCheckin checkin) {
    final scores = {
      'energy': checkin.energy,
      'clarity': checkin.clarity,
      'heart': checkin.heart,
      'sleep': checkin.sleep,
    };
    final best = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final worst = scores.entries.reduce((a, b) => a.value < b.value ? a : b);

    // If the best is high (>65), celebrate it
    if (best.value > 65) {
      return _highCheckinPrescription(best.key, best.value);
    }
    // If the worst is low (<35), address it
    if (worst.value < 35) {
      return _lowCheckinPrescription(worst.key, worst.value);
    }
    // Otherwise, balanced advice
    return const Prescription(
      textEn: 'Your state is balanced today. Channel this equilibrium into focused, intentional action.',
      textRu: 'Твоё состояние сегодня сбалансировано. Направь это равновесие в сфокусированное, намеренное действие.',
      trigger: 'checkin_balanced',
    );
  }

  static Prescription _highCheckinPrescription(String param, int value) {
    switch (param) {
      case 'energy':
        return const Prescription(
          textEn: 'Body is strong — ride this energy into something physical and social.',
          textRu: 'Тело сильно — используй эту энергию для физического и социального.',
          trigger: 'checkin_energy_high',
        );
      case 'clarity':
        return const Prescription(
          textEn: 'Mind is sharp — tackle the hardest intellectual challenge on your list.',
          textRu: 'Ум остр — возьмись за самую сложную интеллектуальную задачу.',
          trigger: 'checkin_clarity_high',
        );
      case 'heart':
        return const Prescription(
          textEn: 'Heart is open — reach out to someone who needs connection today.',
          textRu: 'Сердце открыто — протяни руку тому, кто нуждается в связи сегодня.',
          trigger: 'checkin_heart_high',
        );
      case 'sleep':
        return const Prescription(
          textEn: 'Well-rested and grounded — your foundation is strong. Build on it.',
          textRu: 'Хорошо отдохнул и заземлён — твоя основа крепка. Строй на ней.',
          trigger: 'checkin_sleep_high',
        );
      default:
        return const Prescription(
          textEn: 'Your state is elevated — use this momentum wisely.',
          textRu: 'Твоё состояние приподнято — используй этот импульс мудро.',
          trigger: 'checkin_high',
        );
    }
  }

  static Prescription _lowCheckinPrescription(String param, int value) {
    switch (param) {
      case 'energy':
        return const Prescription(
          textEn: 'Energy is low — honor your limits. Restore before you push.',
          textRu: 'Энергия низкая — уважай свои пределы. Восстановись прежде чем давить.',
          trigger: 'checkin_energy_low',
        );
      case 'clarity':
        return const Prescription(
          textEn: 'Mind feels foggy — simplify. Do one thing at a time, slowly.',
          textRu: 'В голове туман — упрости. Делай одно дело за раз, медленно.',
          trigger: 'checkin_clarity_low',
        );
      case 'heart':
        return const Prescription(
          textEn: 'Heart feels closed — be gentle with yourself. Warmth returns.',
          textRu: 'Сердце закрыто — будь мягче к себе. Тепло вернётся.',
          trigger: 'checkin_heart_low',
        );
      case 'sleep':
        return const Prescription(
          textEn: 'Sleep was poor — go easy today. Prioritize rest tonight.',
          textRu: 'Сон был плохим — не перегружайся сегодня. Отдых сегодня вечером в приоритете.',
          trigger: 'checkin_sleep_low',
        );
      default:
        return const Prescription(
          textEn: 'Something feels depleted — listen to your body and rest.',
          textRu: 'Что-то истощено — прислушайся к телу и отдохни.',
          trigger: 'checkin_low',
        );
    }
  }

  static String _sephiraQualityEn(int id) {
    const qualities = {
      5: 'loving-kindness in action',
      6: 'discipline and boundaries',
      7: 'beauty and harmony',
      8: 'persistence and victory',
      9: 'gratitude and humility',
      10: 'foundation and connection',
      11: 'embodied action',
    };
    return qualities[id] ?? 'spiritual energy';
  }

  static String _sephiraQualityRu(int id) {
    const qualities = {
      5: 'любовь и милосердие в действии',
      6: 'дисциплина и границы',
      7: 'красота и гармония',
      8: 'стойкость и победа',
      9: 'благодарность и смирение',
      10: 'основа и связь',
      11: 'воплощённое действие',
    };
    return qualities[id] ?? 'духовная энергия';
  }
}
