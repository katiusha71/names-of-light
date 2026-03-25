import 'dart:ui';

class CodeItem {
  final int id;
  final String letters;
  final String category;
  final String categoryRu;
  final String meaning;
  final String meaningRu;
  final String description;
  final String descriptionRu;
  final Color color;

  const CodeItem({
    required this.id,
    required this.letters,
    required this.category,
    required this.categoryRu,
    required this.meaning,
    required this.meaningRu,
    required this.description,
    required this.descriptionRu,
    required this.color,
  });

  factory CodeItem.fromJson(Map<String, dynamic> json) {
    return CodeItem(
      id: json['id'] as int,
      letters: json['letters'] as String,
      category: json['category'] as String,
      categoryRu: json['categoryRu'] as String,
      meaning: json['meaning'] as String,
      meaningRu: json['meaningRu'] as String,
      description: json['description'] as String,
      descriptionRu: json['descriptionRu'] as String,
      color: _parseColor(json['color'] as String),
    );
  }

  String getCategory(bool isRussian) => isRussian ? categoryRu : category;
  String getMeaning(bool isRussian) => isRussian ? meaningRu : meaning;
  String getDescription(bool isRussian) => isRussian ? descriptionRu : description;

  static Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) buffer.write('FF');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
