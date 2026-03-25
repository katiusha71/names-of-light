import 'hebrew_calendar.dart';
import 'daily_energy.dart';
import '../models/archetype.dart';
import '../models/user_profile.dart';

/// Birth date → personal Kabbalistic profile.
/// Life path number, personal sephira, KWML/Pillar derivation, and baseline weights.

class BirthProfile {
  /// Calculate life path number from birth date.
  /// Sum all digits, reduce to single digit (keep 11, 22 as master numbers).
  static int lifePathNumber(DateTime birthDate) {
    int sum = _digitSum(birthDate.year) +
        _digitSum(birthDate.month) +
        _digitSum(birthDate.day);

    // Keep reducing until single digit or master number
    while (sum > 22) {
      sum = _digitSum(sum);
    }
    // 11 and 22 are master numbers — keep them
    if (sum == 11 || sum == 22) return sum;
    // Otherwise reduce to single digit
    while (sum > 9) {
      sum = _digitSum(sum);
    }
    return sum;
  }

  static int _digitSum(int n) {
    int sum = 0;
    n = n.abs();
    while (n > 0) {
      sum += n % 10;
      n ~/= 10;
    }
    return sum;
  }

  /// Life path number → personal sephira ID
  static const _lifePathSephiraMap = {
    1: 1,  // Keter
    2: 2,  // Chokmah
    3: 3,  // Binah
    4: 5,  // Chesed
    5: 6,  // Gevurah
    6: 7,  // Tiferet
    7: 8,  // Netzach
    8: 9,  // Hod
    9: 10, // Yesod
    11: 4, // Daat (master number)
    22: 11, // Malkhut (master number)
  };

  /// Get the personal sephira ID for a life path number
  static int personalSephira(int lifePathNumber) {
    return _lifePathSephiraMap[lifePathNumber] ?? 7; // default Tiferet
  }

  /// Get the weekday sephira for the birth day of week
  static int birthWeekdaySephira(DateTime birthDate) {
    return DailyEnergy.weekdaySephira(birthDate);
  }

  /// Get the Hebrew month info for the birth Hebrew month
  static HebrewMonthInfo? birthMonthInfo(DateTime birthDate) {
    final hd = HebrewCalendar.fromDateTime(birthDate);
    return DailyEnergy.hebrewMonthInfo(hd);
  }

  // ===================================================================
  // Reverse mapping: Sephira → KWML/Pillar influence
  // Each sephira has natural affinities with archetypes and pillars.
  // Based on the Tree of Life correspondences:
  //   King  ↔ Keter(1), Tiferet(7)       — leadership, vision, harmony
  //   Warrior ↔ Gevurah(6), Netzach(8)   — discipline, persistence
  //   Magician ↔ Chokmah(2), Binah(3), Hod(9) — wisdom, analysis, intellect
  //   Lover ↔ Chesed(5), Yesod(10)       — kindness, emotional connection
  //
  //   Know  ↔ Chokmah(2), Daat(4), Hod(9)
  //   Dare  ↔ Gevurah(6), Netzach(8), Chesed(5)
  //   Will  ↔ Keter(1), Tiferet(7)
  //   Silent ↔ Binah(3), Yesod(10)
  // ===================================================================

  /// Sephira ID → KWML influence weights (king, warrior, magician, lover)
  static const _sephiraKwml = <int, List<double>>{
    1:  [0.90, 0.20, 0.30, 0.20], // Keter: strong King
    2:  [0.30, 0.15, 0.90, 0.25], // Chokmah: strong Magician
    3:  [0.20, 0.20, 0.85, 0.35], // Binah: strong Magician, some Lover
    4:  [0.40, 0.25, 0.80, 0.35], // Daat: Magician (integration), some King
    5:  [0.25, 0.20, 0.25, 0.90], // Chesed: strong Lover
    6:  [0.30, 0.90, 0.20, 0.15], // Gevurah: strong Warrior
    7:  [0.70, 0.35, 0.35, 0.55], // Tiferet: King + Lover (balance)
    8:  [0.25, 0.75, 0.30, 0.30], // Netzach: Warrior (endurance)
    9:  [0.20, 0.30, 0.80, 0.20], // Hod: Magician (intellect)
    10: [0.20, 0.15, 0.30, 0.80], // Yesod: Lover (emotion/foundation)
    11: [0.45, 0.40, 0.40, 0.45], // Malkhut: balanced grounding
  };

  /// Sephira ID → Pillar influence weights (know, dare, will, silent)
  static const _sephiraPillar = <int, List<double>>{
    1:  [0.30, 0.25, 0.90, 0.20], // Keter: strong Will
    2:  [0.90, 0.20, 0.30, 0.25], // Chokmah: strong Know
    3:  [0.35, 0.15, 0.20, 0.90], // Binah: strong Silent
    4:  [0.80, 0.25, 0.35, 0.40], // Daat: strong Know (integration)
    5:  [0.25, 0.70, 0.30, 0.30], // Chesed: Dare (expanding/giving)
    6:  [0.20, 0.90, 0.35, 0.15], // Gevurah: strong Dare
    7:  [0.35, 0.35, 0.75, 0.40], // Tiferet: Will (harmony requires intention)
    8:  [0.20, 0.75, 0.40, 0.20], // Netzach: Dare (victory/persistence)
    9:  [0.75, 0.25, 0.20, 0.35], // Hod: Know (analysis/study)
    10: [0.25, 0.20, 0.30, 0.75], // Yesod: Silent (inner/receptive)
    11: [0.40, 0.40, 0.45, 0.40], // Malkhut: balanced, slight Will
  };

  /// Life path number character modifiers (additional nuance beyond sephira)
  /// [king, warrior, magician, lover]
  static const _lifePathKwmlMod = <int, List<double>>{
    1: [0.15, 0.05, 0.00, 0.00], // Leaders, initiators
    2: [0.00, 0.00, 0.05, 0.10], // Peacemakers, empaths
    3: [0.05, 0.00, 0.10, 0.08], // Creatives, communicators
    4: [0.00, 0.10, 0.05, 0.00], // Builders, disciplined
    5: [0.00, 0.12, 0.00, 0.05], // Adventurers, dynamic
    6: [0.08, 0.00, 0.00, 0.12], // Nurturers, harmony-seekers
    7: [0.00, 0.00, 0.15, 0.00], // Seekers, mystics
    8: [0.12, 0.08, 0.00, 0.00], // Power, material mastery
    9: [0.05, 0.00, 0.08, 0.10], // Humanitarians, idealists
    11: [0.05, 0.00, 0.15, 0.08], // Visionaries, intuitive
    22: [0.10, 0.08, 0.10, 0.05], // Master builders, all amplified
  };

  /// Derive KWML and Pillar scores from birth date.
  /// Returns a UserProfile with computed values (30-85 range).
  static UserProfile calculateBirthProfile(DateTime birthDate) {
    final lp = lifePathNumber(birthDate);
    final pSephira = personalSephira(lp);
    final wSephira = birthWeekdaySephira(birthDate);
    final monthInfo = birthMonthInfo(birthDate);

    // Accumulate KWML: [king, warrior, magician, lover]
    final kwmlAcc = [0.0, 0.0, 0.0, 0.0];
    // Accumulate Pillars: [know, dare, will, silent]
    final pillarAcc = [0.0, 0.0, 0.0, 0.0];

    // 1. Personal sephira (life path) — primary influence (weight 1.0)
    final pKwml = _sephiraKwml[pSephira]!;
    final pPillar = _sephiraPillar[pSephira]!;
    for (int i = 0; i < 4; i++) {
      kwmlAcc[i] += pKwml[i] * 1.0;
      pillarAcc[i] += pPillar[i] * 1.0;
    }

    // 2. Birth weekday sephira — secondary influence (weight 0.5)
    final wKwml = _sephiraKwml[wSephira]!;
    final wPillar = _sephiraPillar[wSephira]!;
    for (int i = 0; i < 4; i++) {
      kwmlAcc[i] += wKwml[i] * 0.5;
      pillarAcc[i] += wPillar[i] * 0.5;
    }

    // 3. Birth month sephirot — tertiary influence (weight 0.35 each)
    if (monthInfo != null) {
      for (final sid in monthInfo.associatedSephirot) {
        final mKwml = _sephiraKwml[sid]!;
        final mPillar = _sephiraPillar[sid]!;
        for (int i = 0; i < 4; i++) {
          kwmlAcc[i] += mKwml[i] * 0.35;
          pillarAcc[i] += mPillar[i] * 0.35;
        }
      }
    }

    // 4. Life path number character modifier
    final lpMod = _lifePathKwmlMod[lp] ?? [0.0, 0.0, 0.0, 0.0];
    for (int i = 0; i < 4; i++) {
      kwmlAcc[i] += lpMod[i];
    }

    // 5. Day-of-month adds subtle variation (so same month different days differ)
    final dayMod = (birthDate.day % 10) / 100.0; // 0.00 - 0.09
    kwmlAcc[birthDate.day % 4] += dayMod;
    pillarAcc[(birthDate.day + 1) % 4] += dayMod;

    // Convert accumulated values to 30-85 score range.
    // Direct linear scale: score = accValue * 40 + 25, clamped to [30, 85].
    // Accumulated values typically range from ~0.3 (weak) to ~2.0 (very strong),
    // so this produces scores from ~37 to ~85 with natural spread.
    final kwml = <Archetype, double>{};
    final pillars = <Pillar, double>{};

    final archetypes = Archetype.values;
    final pillarValues = Pillar.values;

    for (int i = 0; i < 4; i++) {
      kwml[archetypes[i]] = (kwmlAcc[i] * 40.0 + 25.0).clamp(30.0, 85.0).roundToDouble();
      pillars[pillarValues[i]] = (pillarAcc[i] * 40.0 + 25.0).clamp(30.0, 85.0).roundToDouble();
    }

    return UserProfile(
      kwml: kwml,
      pillars: pillars,
      birthDate: birthDate,
    );
  }

  // ===================================================================
  // Zodiac sign → ruling planet → planetary sephira
  // Each Hebrew month has a zodiac sign with a Kabbalistic planetary ruler.
  // Planetary sephira mapping (Sefer Yetzirah tradition):
  //   Saturn=Binah(3), Jupiter=Chesed(5), Mars=Gevurah(6),
  //   Sun=Tiferet(7), Venus=Netzach(8), Mercury=Hod(9), Moon=Yesod(10)
  // ===================================================================
  static const _monthPlanetarySephira = <int, int>{
    1: 6,   // Nisan=Aries → Mars → Gevurah
    2: 8,   // Iyar=Taurus → Venus → Netzach
    3: 9,   // Sivan=Gemini → Mercury → Hod
    4: 10,  // Tammuz=Cancer → Moon → Yesod
    5: 7,   // Av=Leo → Sun → Tiferet
    6: 9,   // Elul=Virgo → Mercury → Hod
    7: 8,   // Tishrei=Libra → Venus → Netzach
    8: 6,   // Cheshvan=Scorpio → Mars → Gevurah
    9: 5,   // Kislev=Sagittarius → Jupiter → Chesed
    10: 3,  // Tevet=Capricorn → Saturn → Binah
    11: 3,  // Shevat=Aquarius → Saturn → Binah
    12: 5,  // Adar=Pisces → Jupiter → Chesed
    13: 5,  // Adar II=Pisces → Jupiter → Chesed
  };

  // ===================================================================
  // Element → sephirot group (for subtle secondary influence)
  // Fire: Chokmah(2), Gevurah(6)  — dynamic, active
  // Water: Binah(3), Chesed(5)    — receptive, flowing
  // Air: Keter(1), Tiferet(7)     — connecting, harmonizing
  // Earth: Hod(9), Malkhut(11)    — grounding, manifesting
  // ===================================================================
  static const _monthElement = <int, String>{
    1: 'fire', 2: 'earth', 3: 'air', 4: 'water',
    5: 'fire', 6: 'earth', 7: 'air', 8: 'water',
    9: 'fire', 10: 'earth', 11: 'air', 12: 'water', 13: 'water',
  };

  static const _elementSephirot = <String, List<int>>{
    'fire': [2, 6],    // Chokmah, Gevurah
    'water': [3, 5],   // Binah, Chesed
    'air': [1, 7],     // Keter, Tiferet
    'earth': [9, 11],  // Hod, Malkhut
  };

  /// Calculate personal baseline weights for sephira tree.
  /// 7 factors ensure every sephira gets a unique value per person:
  /// 1. Life path sephira +15
  /// 2. Birth weekday sephira +8
  /// 3. Birth month primary sephira +20, secondary +8
  /// 4. Zodiac planetary sephira +10
  /// 5. Element sephirot +4 each
  /// 6. Hebrew day: primary sephira +5, secondary +3
  /// 7. Birth-date hash spread: +1 to +4 per sephira (unique fingerprint)
  static Map<int, double> calculatePersonalBaseline(DateTime birthDate) {
    final weights = <int, double>{};
    for (int i = 1; i <= 11; i++) {
      weights[i] = 50.0;
    }

    final hd = HebrewCalendar.fromDateTime(birthDate);

    // 1. Personal sephira from life path
    final lp = lifePathNumber(birthDate);
    final pSephira = personalSephira(lp);
    weights[pSephira] = weights[pSephira]! + 15.0;

    // 2. Birth weekday sephira
    final wSephira = birthWeekdaySephira(birthDate);
    weights[wSephira] = weights[wSephira]! + 8.0;

    // 3. Birth month associated sephirot (Sefer Yetzirah)
    final monthInfo = birthMonthInfo(birthDate);
    if (monthInfo != null) {
      final sephirot = monthInfo.associatedSephirot;
      if (sephirot.isNotEmpty) {
        weights[sephirot[0]] = weights[sephirot[0]]! + 20.0;
      }
      for (int i = 1; i < sephirot.length; i++) {
        weights[sephirot[i]] = weights[sephirot[i]]! + 8.0;
      }
    }

    // 4. Zodiac planetary ruler sephira
    final planetSephira = _monthPlanetarySephira[hd.month];
    if (planetSephira != null) {
      weights[planetSephira] = weights[planetSephira]! + 10.0;
    }

    // 5. Element group: subtle boost to element's sephirot
    final element = _monthElement[hd.month];
    if (element != null) {
      final elemSephirot = _elementSephirot[element]!;
      for (final sid in elemSephirot) {
        weights[sid] = weights[sid]! + 4.0;
      }
    }

    // 6. Hebrew day of month: each day activates different sephirot
    final dayPrimary = (hd.day - 1) % 11 + 1;
    final daySecondary = (hd.day * 3) % 11 + 1;
    weights[dayPrimary] = weights[dayPrimary]! + 5.0;
    if (daySecondary != dayPrimary) {
      weights[daySecondary] = weights[daySecondary]! + 3.0;
    }

    // 7. Birth-date hash spread: deterministic pseudo-random 1-4 points per sephira
    //    ensures no two birth dates produce identical flat regions
    final seed = hd.year * 397 + hd.month * 31 + hd.day;
    for (int i = 1; i <= 11; i++) {
      final hash = ((seed * 2654435761 + i * 2246822519) >> 16) & 0xFFFF;
      weights[i] = weights[i]! + (hash % 4) + 1.0; // +1 to +4
    }

    return weights;
  }

  /// Get a display summary of the birth profile
  static BirthProfileSummary getSummary(DateTime birthDate, {bool isRu = false}) {
    final lp = lifePathNumber(birthDate);
    final pSephiraId = personalSephira(lp);
    final hd = HebrewCalendar.fromDateTime(birthDate);
    final monthInfo = birthMonthInfo(birthDate);

    return BirthProfileSummary(
      lifePathNumber: lp,
      personalSephiraId: pSephiraId,
      personalSephiraName: DailyEnergy.getSephiraName(pSephiraId, isRu: isRu),
      hebrewBirthday: hd,
      birthMonthInfo: monthInfo,
    );
  }
}

class BirthProfileSummary {
  final int lifePathNumber;
  final int personalSephiraId;
  final String personalSephiraName;
  final HebrewDate hebrewBirthday;
  final HebrewMonthInfo? birthMonthInfo;

  const BirthProfileSummary({
    required this.lifePathNumber,
    required this.personalSephiraId,
    required this.personalSephiraName,
    required this.hebrewBirthday,
    required this.birthMonthInfo,
  });
}
