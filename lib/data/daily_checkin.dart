import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Daily check-in: 4 parameters on 0-100 scale (like fitness ring).
/// 1. Energy (0=exhausted → 100=vibrant) → affects Gevurah(6)/Netzach(8)/Keter(1)
/// 2. Clarity (0=foggy → 100=sharp) → affects Chokmah(2)/Binah(3)/Hod(9)
/// 3. Heart (0=closed → 100=open) → affects Chesed(5)/Tiferet(7)/Yesod(10)
/// 4. Sleep (0=terrible → 100=perfect) → affects Yesod(10)/Malkhut(11)/Binah(3)

class DailyCheckin {
  final int energy;   // 0-100
  final int clarity;  // 0-100
  final int heart;    // 0-100
  final int sleep;    // 0-100
  final DateTime date;

  const DailyCheckin({
    required this.energy,
    required this.clarity,
    required this.heart,
    required this.sleep,
    required this.date,
  });

  /// Default neutral check-in (used when no check-in done today)
  factory DailyCheckin.neutral() => DailyCheckin(
        energy: 50,
        clarity: 50,
        heart: 50,
        sleep: 50,
        date: DateTime.now(),
      );

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Map<String, dynamic> toJson() => {
        'energy': energy,
        'clarity': clarity,
        'heart': heart,
        'sleep': sleep,
        'date': date.toIso8601String(),
      };

  factory DailyCheckin.fromJson(Map<String, dynamic> json) => DailyCheckin(
        energy: json['energy'] as int,
        clarity: json['clarity'] as int,
        heart: json['heart'] as int,
        sleep: (json['sleep'] as int?) ?? 50,
        date: DateTime.parse(json['date'] as String),
      );

  DailyCheckin copyWith({int? energy, int? clarity, int? heart, int? sleep}) =>
      DailyCheckin(
        energy: energy ?? this.energy,
        clarity: clarity ?? this.clarity,
        heart: heart ?? this.heart,
        sleep: sleep ?? this.sleep,
        date: DateTime.now(),
      );

  /// Convert check-in answers (0-100) to sephira adjustment weights.
  /// Returns map of sephira ID → weight (0-100 scale).
  static Map<int, double> checkinToSephiraAdjustments(DailyCheckin? checkin) {
    final weights = <int, double>{};
    for (int i = 1; i <= 11; i++) {
      weights[i] = 50.0; // neutral baseline
    }

    final e = (checkin?.energy ?? 50).toDouble();
    final c = (checkin?.clarity ?? 50).toDouble();
    final h = (checkin?.heart ?? 50).toDouble();
    final s = (checkin?.sleep ?? 50).toDouble();

    // Energy → Gevurah(6), Netzach(8), Keter(1)
    weights[6] = e;
    weights[8] = e;
    weights[1] = e * 0.5 + 25; // partial influence

    // Clarity → Chokmah(2), Binah(3), Hod(9)
    weights[2] = c;
    weights[3] = (c * 0.6 + s * 0.4); // clarity + sleep → understanding
    weights[9] = c;

    // Heart → Chesed(5), Tiferet(7), Yesod(10)
    weights[5] = h;
    weights[7] = h;
    weights[10] = (h * 0.5 + s * 0.5); // heart + sleep → foundation

    // Sleep → Yesod(10), Malkhut(11), Binah(3)
    // Yesod and Binah already blended above
    weights[11] = (e + c + h + s) / 4; // Malkhut = average grounding
    weights[4] = (c + h) / 2; // Daat = integration of clarity and heart

    return weights;
  }

  // === Persistence ===

  static const _storageKey = 'daily_checkin';

  static Future<DailyCheckin?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_storageKey);
      if (str == null) return null;
      final checkin = DailyCheckin.fromJson(json.decode(str) as Map<String, dynamic>);
      // Only return if it's today's check-in
      if (checkin.isToday) return checkin;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(DailyCheckin checkin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(checkin.toJson()));
  }
}
