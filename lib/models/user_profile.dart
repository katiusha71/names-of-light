import 'dart:convert';
import 'archetype.dart';

class UserProfile {
  final Map<Archetype, double> kwml;
  final Map<Pillar, double> pillars;
  final DateTime? birthDate;

  const UserProfile({
    required this.kwml,
    required this.pillars,
    this.birthDate,
  });

  factory UserProfile.empty() => UserProfile(
        kwml: {for (var a in Archetype.values) a: 50.0},
        pillars: {for (var p in Pillar.values) p: 50.0},
      );

  UserProfile copyWith({
    Map<Archetype, double>? kwml,
    Map<Pillar, double>? pillars,
    DateTime? birthDate,
    bool clearBirthDate = false,
  }) =>
      UserProfile(
        kwml: kwml ?? Map.of(this.kwml),
        pillars: pillars ?? Map.of(this.pillars),
        birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      );

  Map<String, dynamic> toJson() => {
        'kwml': kwml.map((k, v) => MapEntry(k.name, v)),
        'pillars': pillars.map((k, v) => MapEntry(k.name, v)),
        if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final kwmlMap = <Archetype, double>{};
    final kwmlJson = json['kwml'] as Map<String, dynamic>? ?? {};
    for (final a in Archetype.values) {
      kwmlMap[a] = (kwmlJson[a.name] as num?)?.toDouble() ?? 50.0;
    }
    final pillarMap = <Pillar, double>{};
    final pillarJson = json['pillars'] as Map<String, dynamic>? ?? {};
    for (final p in Pillar.values) {
      pillarMap[p] = (pillarJson[p.name] as num?)?.toDouble() ?? 50.0;
    }
    DateTime? birthDate;
    if (json['birthDate'] != null) {
      birthDate = DateTime.tryParse(json['birthDate'] as String);
    }
    return UserProfile(kwml: kwmlMap, pillars: pillarMap, birthDate: birthDate);
  }

  String encode() => json.encode(toJson());

  factory UserProfile.decode(String s) =>
      UserProfile.fromJson(json.decode(s) as Map<String, dynamic>);
}
