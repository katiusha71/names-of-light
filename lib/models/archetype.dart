enum Archetype { king, warrior, magician, lover }

enum ArchetypeLevel { high, low }

enum Pillar { know, dare, will, silent }

extension ArchetypeExtension on Archetype {
  String get nameEn {
    switch (this) {
      case Archetype.king:
        return 'King';
      case Archetype.warrior:
        return 'Warrior';
      case Archetype.magician:
        return 'Magician';
      case Archetype.lover:
        return 'Lover';
    }
  }

  String get nameRu {
    switch (this) {
      case Archetype.king:
        return 'Король';
      case Archetype.warrior:
        return 'Воин';
      case Archetype.magician:
        return 'Маг';
      case Archetype.lover:
        return 'Любовник';
    }
  }

  String getName(bool isRussian) => isRussian ? nameRu : nameEn;

  String get icon {
    switch (this) {
      case Archetype.king:
        return '👑';
      case Archetype.warrior:
        return '⚔️';
      case Archetype.magician:
        return '🔮';
      case Archetype.lover:
        return '❤️';
    }
  }
}

extension ArchetypeLevelExtension on ArchetypeLevel {
  String get nameEn => this == ArchetypeLevel.high ? 'High' : 'Low';
  String get nameRu => this == ArchetypeLevel.high ? 'Высокий' : 'Низкий';
  String getName(bool isRussian) => isRussian ? nameRu : nameEn;
}

extension PillarExtension on Pillar {
  String get nameEn {
    switch (this) {
      case Pillar.know:
        return 'Know';
      case Pillar.dare:
        return 'Dare';
      case Pillar.will:
        return 'Will';
      case Pillar.silent:
        return 'Silent';
    }
  }

  String get nameRu {
    switch (this) {
      case Pillar.know:
        return 'Знать';
      case Pillar.dare:
        return 'Дерзать';
      case Pillar.will:
        return 'Желать';
      case Pillar.silent:
        return 'Молчать';
    }
  }

  String getName(bool isRussian) => isRussian ? nameRu : nameEn;

  String get latinName {
    switch (this) {
      case Pillar.know:
        return 'Noscere';
      case Pillar.dare:
        return 'Audere';
      case Pillar.will:
        return 'Velle';
      case Pillar.silent:
        return 'Tacere';
    }
  }
}

class CompatibilityResult {
  final int recommended72NameId;
  final int recommendedSephiraId;
  final String strategyEn;
  final String strategyRu;

  const CompatibilityResult({
    required this.recommended72NameId,
    required this.recommendedSephiraId,
    required this.strategyEn,
    required this.strategyRu,
  });

  String getStrategy(bool isRussian) => isRussian ? strategyRu : strategyEn;
}
