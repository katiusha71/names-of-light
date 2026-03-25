import 'dart:ui';

class SephiraItem {
  final int id;
  final String nameHebrew;
  final String nameEnglish;
  final String nameRussian;
  final String meaningEn;
  final String meaningRu;
  final String description;
  final String descriptionRu;
  final Color color;
  final List<int> associated72NameIds;
  final double x;
  final double y;
  final bool isHidden;

  const SephiraItem({
    required this.id,
    required this.nameHebrew,
    required this.nameEnglish,
    required this.nameRussian,
    this.meaningEn = '',
    this.meaningRu = '',
    required this.description,
    required this.descriptionRu,
    required this.color,
    required this.associated72NameIds,
    required this.x,
    required this.y,
    this.isHidden = false,
  });

  factory SephiraItem.fromJson(Map<String, dynamic> json) {
    return SephiraItem(
      id: json['id'] as int,
      nameHebrew: json['nameHebrew'] as String,
      nameEnglish: json['nameEnglish'] as String,
      nameRussian: json['nameRussian'] as String,
      meaningEn: json['meaningEn'] as String? ?? '',
      meaningRu: json['meaningRu'] as String? ?? '',
      description: json['description'] as String,
      descriptionRu: json['descriptionRu'] as String,
      color: _parseColor(json['color'] as String),
      associated72NameIds: (json['associated72NameIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  /// Transliteration (Keter / Кетер)
  String getName(bool isRussian) => isRussian ? nameRussian : nameEnglish;

  /// Translation (Crown / Корона)
  String getMeaning(bool isRussian) => isRussian ? meaningRu : meaningEn;

  String getDescription(bool isRussian) =>
      isRussian ? descriptionRu : description;

  static Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) buffer.write('FF');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
