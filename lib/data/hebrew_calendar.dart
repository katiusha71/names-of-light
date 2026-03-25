// Pure Dart implementation of Gregorian → Hebrew date conversion.
// Based on Nachum Dershowitz & Edward Reingold's "Calendrical Calculations"
// (4th edition) — the standard reference algorithm used worldwide.

class HebrewDate {
  final int year;
  final int month; // 1=Nisan, 2=Iyar, ..., 7=Tishrei, ..., 12=Adar (13=Adar II in leap)
  final int day;

  const HebrewDate({required this.year, required this.month, required this.day});

  static const monthNamesEn = [
    '',
    'Nisan', 'Iyar', 'Sivan', 'Tammuz', 'Av', 'Elul',
    'Tishrei', 'Cheshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar', 'Adar II',
  ];

  static const monthNamesRu = [
    '',
    'Нисан', 'Ияр', 'Сиван', 'Таммуз', 'Ав', 'Элуль',
    'Тишрей', 'Хешван', 'Кислев', 'Тевет', 'Шват', 'Адар', 'Адар II',
  ];

  String get monthNameEn => monthNamesEn[month];
  String get monthNameRu => monthNamesRu[month];
  String getMonthName(bool isRu) => isRu ? monthNameRu : monthNameEn;

  @override
  String toString() => '$day $monthNameEn $year';
}

class HebrewCalendar {
  // ============================================================
  // Hebrew epoch in R.D. (Rata Die) fixed-day numbering.
  // R.D. 1 = January 1, 1 CE (proleptic Gregorian).
  // Hebrew epoch = 1 Tishrei year 1 = R.D. HEBREW_EPOCH.
  // From Reingold-Dershowitz: fixed-from-julian(october, 7, -3760)
  // ============================================================
  static const _hebrewEpoch = -1373427;

  /// Leap years in the 19-year Metonic cycle
  static bool isHebrewLeapYear(int year) {
    return ((7 * year + 1) % 19) < 7;
  }

  /// Number of months in a Hebrew year
  static int monthsInYear(int year) => isHebrewLeapYear(year) ? 13 : 12;

  // ============================================================
  // Core algorithm: Hebrew elapsed days (Reingold-Dershowitz)
  //
  // Computes the number of days from the Hebrew epoch (1 Tishrei AM 1)
  // to 1 Tishrei of the given year, with all 4 dechiyot applied.
  // ============================================================

  /// Number of months elapsed from epoch to the start of Hebrew year.
  /// Uses the formula: floor((235 * year - 234) / 19)
  static int _monthsElapsed(int year) {
    return (235 * year - 234) ~/ 19;
  }

  /// Compute the day number of 1 Tishrei for a given Hebrew year
  /// relative to the Hebrew epoch (1 Tishrei year 1 = day 1).
  static int _hebrewElapsedDays(int year) {
    final months = _monthsElapsed(year);

    // Parts elapsed = initial BaHaRaD parts + accumulated lunation parts.
    // A lunation = 29 days + 12 hours + 793 parts.
    // The 29 days per month are tracked separately in conjunction_day.
    // The fractional 12h 793p = 13753 parts per month.
    // BaHaRaD initial: 11 hours 204 parts = 12084 parts.
    // (11h rather than 5h because R-D counts from midnight, not 6 PM)
    final partsElapsed = 12084 + 13753 * months;
    final hoursElapsed = partsElapsed ~/ 1080;

    // Conjunction day: 1 base + 29 per month + hours overflow
    final conjunctionDay = 1 + 29 * months + hoursElapsed ~/ 24;
    final conjunctionParts =
        1080 * (hoursElapsed % 24) + partsElapsed % 1080;

    // --- Apply postponement rules (dechiyot) ---

    // Day of week: conjunctionDay % 7
    // 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat

    int alternativeDay;

    // Dechiyah 2 (Molad Zaken): conjunction at or after 18h (19440 parts in day)
    // Dechiyah 3 (GaTRaD): non-leap, Tuesday, >= 9h 204p (9924 parts)
    // Dechiyah 4 (BeTUTaKPaT): post-leap, Monday, >= 15h 589p (16789 parts)
    if (conjunctionParts >= 19440 ||
        (conjunctionDay % 7 == 2 &&
            conjunctionParts >= 9924 &&
            !isHebrewLeapYear(year)) ||
        (conjunctionDay % 7 == 1 &&
            conjunctionParts >= 16789 &&
            isHebrewLeapYear(year - 1))) {
      alternativeDay = conjunctionDay + 1;
    } else {
      alternativeDay = conjunctionDay;
    }

    // Dechiyah 1 (Lo ADU): Rosh Hashanah cannot fall on Sunday(0), Wednesday(3), Friday(5)
    final dow = alternativeDay % 7;
    if (dow == 0 || dow == 3 || dow == 5) {
      return alternativeDay + 1;
    }
    return alternativeDay;
  }

  /// R.D. fixed day of 1 Tishrei for a given Hebrew year
  static int _hebrewNewYear(int year) {
    return _hebrewEpoch - 1 + _hebrewElapsedDays(year);
  }

  /// Length of a Hebrew year in days
  static int hebrewYearLength(int year) {
    return _hebrewNewYear(year + 1) - _hebrewNewYear(year);
  }

  /// Whether Cheshvan has 30 days (complete year: 355 or 385 days)
  static bool _isCheshvanLong(int year) {
    final len = hebrewYearLength(year);
    return len == 355 || len == 385;
  }

  /// Whether Kislev has 30 days (not deficient year: not 353 or 383 days)
  static bool _isKislevLong(int year) {
    final len = hebrewYearLength(year);
    return len != 353 && len != 383;
  }

  /// Number of days in a given Hebrew month
  static int daysInMonth(int year, int month) {
    switch (month) {
      case 1: return 30; // Nisan
      case 2: return 29; // Iyar
      case 3: return 30; // Sivan
      case 4: return 29; // Tammuz
      case 5: return 30; // Av
      case 6: return 29; // Elul
      case 7: return 30; // Tishrei
      case 8: return _isCheshvanLong(year) ? 30 : 29; // Cheshvan
      case 9: return _isKislevLong(year) ? 30 : 29; // Kislev
      case 10: return 29; // Tevet
      case 11: return 30; // Shevat
      case 12: return isHebrewLeapYear(year) ? 30 : 29; // Adar
      case 13: return 29; // Adar II
      default: return 30;
    }
  }

  // ============================================================
  // Gregorian calendar → R.D. fixed day number
  // ============================================================

  static bool _isGregorianLeap(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  /// Convert Gregorian date to R.D. (Rata Die) fixed day number.
  /// R.D. 1 = January 1, 1 CE.
  static int _gregorianToFixed(int year, int month, int day) {
    final y = year - 1;
    int fixed = 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400;
    const cumDays = [0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    fixed += cumDays[month] + day;
    if (month > 2 && _isGregorianLeap(year)) fixed += 1;
    return fixed;
  }

  // ============================================================
  // R.D. fixed day → Hebrew date
  // ============================================================

  static HebrewDate _fixedToHebrew(int fixedDay) {
    // Approximate Hebrew year
    int hYear = ((fixedDay - _hebrewEpoch) ~/ 366) + 1;

    // Adjust: find the correct year
    while (_hebrewNewYear(hYear) > fixedDay) {
      hYear--;
    }
    while (_hebrewNewYear(hYear + 1) <= fixedDay) {
      hYear++;
    }

    // Day within the Hebrew year (1-based)
    int dayOfYear = fixedDay - _hebrewNewYear(hYear) + 1;

    // Walk through months in civil order (starting from Tishrei)
    final monthOrder = _monthOrder(hYear);
    int hMonth = monthOrder.first;
    int daysAcc = 0;

    for (final m in monthOrder) {
      final mDays = daysInMonth(hYear, m);
      if (dayOfYear <= daysAcc + mDays) {
        hMonth = m;
        break;
      }
      daysAcc += mDays;
    }

    final hDay = dayOfYear - daysAcc;
    return HebrewDate(year: hYear, month: hMonth, day: hDay);
  }

  /// Order of months starting from Tishrei (civil year order)
  static List<int> _monthOrder(int year) {
    return [
      7, 8, 9, 10, 11, 12,
      if (isHebrewLeapYear(year)) 13,
      1, 2, 3, 4, 5, 6,
    ];
  }

  // ============================================================
  // Public API
  // ============================================================

  static HebrewDate gregorianToHebrew(int gYear, int gMonth, int gDay) {
    final fixed = _gregorianToFixed(gYear, gMonth, gDay);
    return _fixedToHebrew(fixed);
  }

  static HebrewDate fromDateTime(DateTime dt) {
    return gregorianToHebrew(dt.year, dt.month, dt.day);
  }

  static String formatHebrew(DateTime dt, {bool isRu = false}) {
    final hd = fromDateTime(dt);
    return '${hd.day} ${hd.getMonthName(isRu)} ${hd.year}';
  }
}
