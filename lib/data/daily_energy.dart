import 'hebrew_calendar.dart';

/// Daily cosmic energy from Hebrew calendar: weekday sephira, month info, Omer cycle.

class HebrewMonthInfo {
  final String letterEn;
  final String letterHe;
  final String zodiacEn;
  final String zodiacRu;
  final String senseEn;
  final String senseRu;
  final String tribeEn;
  final String tribeRu;
  final List<int> associatedSephirot; // sephira IDs influenced by this month

  const HebrewMonthInfo({
    required this.letterEn,
    required this.letterHe,
    required this.zodiacEn,
    required this.zodiacRu,
    required this.senseEn,
    required this.senseRu,
    required this.tribeEn,
    required this.tribeRu,
    required this.associatedSephirot,
  });

  String getZodiac(bool isRu) => isRu ? zodiacRu : zodiacEn;
  String getSense(bool isRu) => isRu ? senseRu : senseEn;
  String getTribe(bool isRu) => isRu ? tribeRu : tribeEn;
}

class DailyEnergy {
  /// Sephira IDs: 1=Keter, 2=Chokmah, 3=Binah, 4=Daat, 5=Chesed,
  /// 6=Gevurah, 7=Tiferet, 8=Netzach, 9=Hod, 10=Yesod, 11=Malkhut

  /// The 7 lower sephirot used in Omer counting
  static const lowerSephirot = [5, 6, 7, 8, 9, 10, 11]; // Chesed→Malkhut

  /// Day of week → Sephira mapping (from Sefer Yetzirah)
  /// DateTime.weekday: 1=Mon, 2=Tue, ..., 7=Sun
  static const _weekdaySephiraMap = {
    DateTime.sunday: 5,    // Chesed
    DateTime.monday: 6,    // Gevurah
    DateTime.tuesday: 7,   // Tiferet
    DateTime.wednesday: 8, // Netzach
    DateTime.thursday: 9,  // Hod
    DateTime.friday: 10,   // Yesod
    DateTime.saturday: 11, // Malkhut
  };

  static const _weekdayPlanetEn = {
    DateTime.sunday: 'Sun',
    DateTime.monday: 'Moon',
    DateTime.tuesday: 'Mars',
    DateTime.wednesday: 'Mercury',
    DateTime.thursday: 'Jupiter',
    DateTime.friday: 'Venus',
    DateTime.saturday: 'Saturn',
  };

  static const _weekdayPlanetRu = {
    DateTime.sunday: 'Солнце',
    DateTime.monday: 'Луна',
    DateTime.tuesday: 'Марс',
    DateTime.wednesday: 'Меркурий',
    DateTime.thursday: 'Юпитер',
    DateTime.friday: 'Венера',
    DateTime.saturday: 'Сатурн',
  };

  static const _weekdayLetterHe = {
    DateTime.sunday: 'ב',
    DateTime.monday: 'ג',
    DateTime.tuesday: 'ד',
    DateTime.wednesday: 'כ',
    DateTime.thursday: 'פ',
    DateTime.friday: 'ר',
    DateTime.saturday: 'ת',
  };

  /// Sephira name lookup
  static const sephiraNames = {
    1: 'Keter', 2: 'Chokmah', 3: 'Binah', 4: 'Daat', 5: 'Chesed',
    6: 'Gevurah', 7: 'Tiferet', 8: 'Netzach', 9: 'Hod', 10: 'Yesod', 11: 'Malkhut',
  };

  static const sephiraNamesRu = {
    1: 'Кетер', 2: 'Хокма', 3: 'Бина', 4: 'Даат', 5: 'Хесед',
    6: 'Гвура', 7: 'Тиферет', 8: 'Нецах', 9: 'Ход', 10: 'Йесод', 11: 'Малхут',
  };

  static String getSephiraName(int id, {bool isRu = false}) =>
      isRu ? (sephiraNamesRu[id] ?? '') : (sephiraNames[id] ?? '');

  /// Hebrew month → associations
  static const _monthInfo = {
    1: HebrewMonthInfo( // Nisan
      letterEn: 'Hei', letterHe: 'ה', zodiacEn: 'Aries', zodiacRu: 'Овен',
      senseEn: 'Speech', senseRu: 'Речь', tribeEn: 'Judah', tribeRu: 'Иегуда',
      associatedSephirot: [5, 7], // Chesed, Tiferet (redemption/harmony)
    ),
    2: HebrewMonthInfo( // Iyar
      letterEn: 'Vav', letterHe: 'ו', zodiacEn: 'Taurus', zodiacRu: 'Телец',
      senseEn: 'Thought', senseRu: 'Мысль', tribeEn: 'Issachar', tribeRu: 'Иссахар',
      associatedSephirot: [2, 3], // Chokmah, Binah (contemplation)
    ),
    3: HebrewMonthInfo( // Sivan
      letterEn: 'Zayin', letterHe: 'ז', zodiacEn: 'Gemini', zodiacRu: 'Близнецы',
      senseEn: 'Motion', senseRu: 'Движение', tribeEn: 'Zebulun', tribeRu: 'Зевулун',
      associatedSephirot: [7, 9], // Tiferet, Hod (duality/balance)
    ),
    4: HebrewMonthInfo( // Tammuz
      letterEn: 'Chet', letterHe: 'ח', zodiacEn: 'Cancer', zodiacRu: 'Рак',
      senseEn: 'Sight', senseRu: 'Зрение', tribeEn: 'Reuben', tribeRu: 'Реувен',
      associatedSephirot: [10, 5], // Yesod, Chesed (emotion/nurture)
    ),
    5: HebrewMonthInfo( // Av
      letterEn: 'Tet', letterHe: 'ט', zodiacEn: 'Leo', zodiacRu: 'Лев',
      senseEn: 'Hearing', senseRu: 'Слух', tribeEn: 'Shimon', tribeRu: 'Шимон',
      associatedSephirot: [6, 1], // Gevurah, Keter (strength/judgment)
    ),
    6: HebrewMonthInfo( // Elul
      letterEn: 'Yod', letterHe: 'י', zodiacEn: 'Virgo', zodiacRu: 'Дева',
      senseEn: 'Action', senseRu: 'Действие', tribeEn: 'Gad', tribeRu: 'Гад',
      associatedSephirot: [9, 11], // Hod, Malkhut (service/refinement)
    ),
    7: HebrewMonthInfo( // Tishrei
      letterEn: 'Lamed', letterHe: 'ל', zodiacEn: 'Libra', zodiacRu: 'Весы',
      senseEn: 'Touch', senseRu: 'Осязание', tribeEn: 'Ephraim', tribeRu: 'Эфраим',
      associatedSephirot: [7, 5, 6], // Tiferet, Chesed, Gevurah (balance)
    ),
    8: HebrewMonthInfo( // Cheshvan
      letterEn: 'Nun', letterHe: 'נ', zodiacEn: 'Scorpio', zodiacRu: 'Скорпион',
      senseEn: 'Smell', senseRu: 'Обоняние', tribeEn: 'Menashe', tribeRu: 'Менаше',
      associatedSephirot: [10, 6], // Yesod, Gevurah (depth/transformation)
    ),
    9: HebrewMonthInfo( // Kislev
      letterEn: 'Samekh', letterHe: 'ס', zodiacEn: 'Sagittarius', zodiacRu: 'Стрелец',
      senseEn: 'Sleep', senseRu: 'Сон', tribeEn: 'Benjamin', tribeRu: 'Биньямин',
      associatedSephirot: [8, 10], // Netzach, Yesod (trust/dreams)
    ),
    10: HebrewMonthInfo( // Tevet
      letterEn: 'Ayin', letterHe: 'ע', zodiacEn: 'Capricorn', zodiacRu: 'Козерог',
      senseEn: 'Anger', senseRu: 'Гнев', tribeEn: 'Dan', tribeRu: 'Дан',
      associatedSephirot: [6, 11], // Gevurah, Malkhut (discipline/earth)
    ),
    11: HebrewMonthInfo( // Shevat
      letterEn: 'Tzadi', letterHe: 'צ', zodiacEn: 'Aquarius', zodiacRu: 'Водолей',
      senseEn: 'Taste', senseRu: 'Вкус', tribeEn: 'Asher', tribeRu: 'Ашер',
      associatedSephirot: [2, 8], // Chokmah, Netzach (innovation/vision)
    ),
    12: HebrewMonthInfo( // Adar
      letterEn: 'Qof', letterHe: 'ק', zodiacEn: 'Pisces', zodiacRu: 'Рыбы',
      senseEn: 'Laughter', senseRu: 'Смех', tribeEn: 'Naphtali', tribeRu: 'Нафтали',
      associatedSephirot: [5, 7], // Chesed, Tiferet (joy/compassion)
    ),
    13: HebrewMonthInfo( // Adar II (same associations as Adar)
      letterEn: 'Qof', letterHe: 'ק', zodiacEn: 'Pisces', zodiacRu: 'Рыбы',
      senseEn: 'Laughter', senseRu: 'Смех', tribeEn: 'Naphtali', tribeRu: 'Нафтали',
      associatedSephirot: [5, 7],
    ),
  };

  // === Public API ===

  /// Get today's weekday sephira ID
  static int weekdaySephira(DateTime date) {
    return _weekdaySephiraMap[date.weekday]!;
  }

  /// Get today's weekday Hebrew letter
  static String weekdayLetter(DateTime date) {
    return _weekdayLetterHe[date.weekday]!;
  }

  /// Get today's planet name
  static String weekdayPlanet(DateTime date, {bool isRu = false}) {
    return isRu ? _weekdayPlanetRu[date.weekday]! : _weekdayPlanetEn[date.weekday]!;
  }

  /// Get Hebrew month info for a given Hebrew date
  static HebrewMonthInfo? hebrewMonthInfo(HebrewDate hd) {
    return _monthInfo[hd.month];
  }

  /// Calculate the Omer day (1-49) for a given Hebrew date.
  /// Omer: 16 Nisan to 5 Sivan (49 days).
  /// Returns null if outside the Omer period.
  static int? omerDay(HebrewDate hd) {
    // 16 Nisan (month 1, day 16) through 5 Sivan (month 3, day 5)
    if (hd.month == 1 && hd.day >= 16) {
      return hd.day - 15; // day 16 = omer 1, day 30 = omer 15
    } else if (hd.month == 2) {
      return 15 + hd.day; // Iyar: 15 + 1..29
    } else if (hd.month == 3 && hd.day <= 5) {
      return 44 + hd.day; // Sivan 1 = omer 45, Sivan 5 = omer 49
    }
    return null;
  }

  /// Get the sephira pair for a given Omer day (1-49).
  /// Returns (innerSephira, outerSephira) — sephira within sephira.
  static (int, int) omerSephirot(int omerDay) {
    final weekIndex = (omerDay - 1) ~/ 7;
    final dayIndex = (omerDay - 1) % 7;
    return (lowerSephirot[dayIndex], lowerSephirot[weekIndex]);
  }

  /// Extended Omer: year-round 49-day cycle using dayOfYear % 49 + 1
  static int extendedOmerDay(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return (dayOfYear - 1) % 49 + 1;
  }

  /// Calculate daily cosmic weights for all sephirot.
  /// Base all at 50. Weekday sephira +8, month sephirot +4, omer inner +6 / outer +3.
  /// Kept moderate so birth profile remains the dominant influence.
  static Map<int, double> calculateDailyCosmicWeights(DateTime date) {
    final weights = <int, double>{};
    for (int i = 1; i <= 11; i++) {
      weights[i] = 50.0;
    }

    // Weekday sephira bonus
    final wSephira = weekdaySephira(date);
    weights[wSephira] = weights[wSephira]! + 8.0;

    // Hebrew month associations
    final hd = HebrewCalendar.fromDateTime(date);
    final monthInfo = hebrewMonthInfo(hd);
    if (monthInfo != null) {
      for (final sid in monthInfo.associatedSephirot) {
        weights[sid] = weights[sid]! + 4.0;
      }
    }

    // Omer sephirot (literal period)
    final omer = omerDay(hd);
    if (omer != null) {
      final (inner, outer) = omerSephirot(omer);
      weights[inner] = weights[inner]! + 8.0;
      weights[outer] = weights[outer]! + 4.0;
    } else {
      // Extended Omer cycle (year-round)
      final extOmer = extendedOmerDay(date);
      final (inner, outer) = omerSephirot(extOmer);
      weights[inner] = weights[inner]! + 6.0;
      weights[outer] = weights[outer]! + 3.0;
    }

    return weights;
  }

  /// Get a summary of today's cosmic energy for display
  static CosmicSummary getCosmicSummary(DateTime date, {bool isRu = false}) {
    final hd = HebrewCalendar.fromDateTime(date);
    final wSephiraId = weekdaySephira(date);
    final monthInfo = hebrewMonthInfo(hd);
    final omer = omerDay(hd);

    String? omerText;
    if (omer != null) {
      final (inner, outer) = omerSephirot(omer);
      final innerName = getSephiraName(inner, isRu: isRu);
      final outerName = getSephiraName(outer, isRu: isRu);
      omerText = isRu
          ? 'Омер день $omer: $innerName в $outerName'
          : 'Omer Day $omer: $innerName in $outerName';
    }

    return CosmicSummary(
      hebrewDate: hd,
      weekdaySephiraId: wSephiraId,
      weekdaySephiraName: getSephiraName(wSephiraId, isRu: isRu),
      weekdayLetter: weekdayLetter(date),
      weekdayPlanet: weekdayPlanet(date, isRu: isRu),
      monthInfo: monthInfo,
      omerDay: omer,
      omerText: omerText,
      extendedOmerDay: extendedOmerDay(date),
    );
  }
}

class CosmicSummary {
  final HebrewDate hebrewDate;
  final int weekdaySephiraId;
  final String weekdaySephiraName;
  final String weekdayLetter;
  final String weekdayPlanet;
  final HebrewMonthInfo? monthInfo;
  final int? omerDay;
  final String? omerText;
  final int extendedOmerDay;

  const CosmicSummary({
    required this.hebrewDate,
    required this.weekdaySephiraId,
    required this.weekdaySephiraName,
    required this.weekdayLetter,
    required this.weekdayPlanet,
    required this.monthInfo,
    required this.omerDay,
    required this.omerText,
    required this.extendedOmerDay,
  });
}
