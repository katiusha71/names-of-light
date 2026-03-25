class CombinationItem {
  final int id;
  final String name;
  final String nameRu;
  final String description;
  final String descriptionRu;
  final String category;
  final String categoryRu;
  final List<int> codeIds;
  final String icon;
  final bool isCustom;

  const CombinationItem({
    required this.id,
    required this.name,
    required this.nameRu,
    required this.description,
    required this.descriptionRu,
    required this.category,
    required this.categoryRu,
    required this.codeIds,
    required this.icon,
    this.isCustom = false,
  });

  factory CombinationItem.fromJson(Map<String, dynamic> json) {
    return CombinationItem(
      id: json['id'] as int,
      name: json['name'] as String,
      nameRu: json['nameRu'] as String,
      description: json['description'] as String,
      descriptionRu: json['descriptionRu'] as String,
      category: json['category'] as String,
      categoryRu: json['categoryRu'] as String,
      codeIds: (json['codes'] as List<dynamic>).cast<int>(),
      icon: json['icon'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameRu': nameRu,
      'description': description,
      'descriptionRu': descriptionRu,
      'category': category,
      'categoryRu': categoryRu,
      'codes': codeIds,
      'icon': icon,
      'isCustom': isCustom,
    };
  }

  CombinationItem copyWith({
    int? id,
    String? name,
    String? nameRu,
    String? description,
    String? descriptionRu,
    String? category,
    String? categoryRu,
    List<int>? codeIds,
    String? icon,
    bool? isCustom,
  }) {
    return CombinationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRu: nameRu ?? this.nameRu,
      description: description ?? this.description,
      descriptionRu: descriptionRu ?? this.descriptionRu,
      category: category ?? this.category,
      categoryRu: categoryRu ?? this.categoryRu,
      codeIds: codeIds ?? this.codeIds,
      icon: icon ?? this.icon,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  String getName(bool isRussian) => isRussian ? nameRu : name;
  String getDescription(bool isRussian) => isRussian ? descriptionRu : description;
  String getCategory(bool isRussian) => isRussian ? categoryRu : category;
}
