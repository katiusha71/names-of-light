import '../models/archetype.dart';

class ActivePattern {
  final String id;
  final String nameEn;
  final String nameRu;
  final String descEn;
  final String descRu;
  final String icon;
  final bool Function(Map<Archetype, double> kwml, Map<Pillar, double> pillars)
      condition;

  const ActivePattern({
    required this.id,
    required this.nameEn,
    required this.nameRu,
    required this.descEn,
    required this.descRu,
    required this.icon,
    required this.condition,
  });

  String getName(bool isRu) => isRu ? nameRu : nameEn;
  String getDesc(bool isRu) => isRu ? descRu : descEn;
}

bool _high(double v) => v >= 70;
bool _low(double v) => v <= 35;

final List<ActivePattern> allPatterns = [
  ActivePattern(
    id: 'pseudo_productivity',
    nameEn: 'Pseudo-Productivity',
    nameRu: 'Псевдо-продуктивность',
    descEn: 'Busy without depth. Action without understanding.',
    descRu: 'Занятость без глубины. Действие без понимания.',
    icon: '~',
    condition: (kwml, pillars) =>
        _high(pillars[Pillar.will]!) &&
        _low(pillars[Pillar.know]!) &&
        _low(pillars[Pillar.silent]!),
  ),
  ActivePattern(
    id: 'shadow_king',
    nameEn: 'Shadow King',
    nameRu: 'Теневой Король',
    descEn: 'Authority without empathy. Control without connection.',
    descRu: 'Власть без эмпатии. Контроль без связи.',
    icon: '!',
    condition: (kwml, pillars) =>
        _high(kwml[Archetype.king]!) && _low(kwml[Archetype.lover]!),
  ),
  ActivePattern(
    id: 'burnout_risk',
    nameEn: 'Burnout Risk',
    nameRu: 'Риск выгорания',
    descEn: 'Pushing hard without rest or emotional replenishment.',
    descRu: 'Давление без отдыха и эмоционального восполнения.',
    icon: '!',
    condition: (kwml, pillars) =>
        _high(kwml[Archetype.warrior]!) &&
        _low(kwml[Archetype.lover]!) &&
        _low(pillars[Pillar.silent]!),
  ),
  ActivePattern(
    id: 'analysis_paralysis',
    nameEn: 'Analysis Paralysis',
    nameRu: 'Аналитический паралич',
    descEn: 'Overthinking prevents action. Knowledge without courage.',
    descRu: 'Переанализ мешает действию. Знание без смелости.',
    icon: '?',
    condition: (kwml, pillars) =>
        _high(pillars[Pillar.know]!) &&
        _low(pillars[Pillar.dare]!) &&
        _low(pillars[Pillar.will]!),
  ),
  ActivePattern(
    id: 'escapism',
    nameEn: 'Escapism',
    nameRu: 'Эскапизм',
    descEn: 'Pleasure-seeking to avoid responsibility and challenge.',
    descRu: 'Поиск удовольствий для избегания ответственности и вызовов.',
    icon: '~',
    condition: (kwml, pillars) =>
        _high(kwml[Archetype.lover]!) &&
        _low(kwml[Archetype.warrior]!) &&
        _low(kwml[Archetype.king]!),
  ),
  ActivePattern(
    id: 'lone_wolf',
    nameEn: 'Lone Wolf',
    nameRu: 'Одинокий волк',
    descEn: 'Self-reliance becomes isolation. Strength without vulnerability.',
    descRu: 'Самодостаточность превращается в изоляцию. Сила без уязвимости.',
    icon: '!',
    condition: (kwml, pillars) =>
        _high(kwml[Archetype.warrior]!) &&
        _low(kwml[Archetype.lover]!) &&
        _low(kwml[Archetype.king]!),
  ),
  ActivePattern(
    id: 'trickster',
    nameEn: 'Trickster',
    nameRu: 'Трикстер',
    descEn: 'Cleverness without moral grounding. Insight used for manipulation.',
    descRu: 'Хитрость без моральной опоры. Проницательность для манипуляций.',
    icon: '?',
    condition: (kwml, pillars) =>
        _high(kwml[Archetype.magician]!) &&
        _low(kwml[Archetype.king]!) &&
        _low(pillars[Pillar.silent]!),
  ),
  ActivePattern(
    id: 'dreamer',
    nameEn: 'Dreamer',
    nameRu: 'Мечтатель',
    descEn: 'Vision without grounded action. Inspiration without execution.',
    descRu: 'Видение без заземлённого действия. Вдохновение без реализации.',
    icon: '~',
    condition: (kwml, pillars) =>
        _high(kwml[Archetype.magician]!) &&
        _low(kwml[Archetype.warrior]!) &&
        _low(pillars[Pillar.dare]!),
  ),
  ActivePattern(
    id: 'rigid_order',
    nameEn: 'Rigid Order',
    nameRu: 'Жёсткий порядок',
    descEn: 'Structure without flexibility. Rules without compassion.',
    descRu: 'Структура без гибкости. Правила без сострадания.',
    icon: '!',
    condition: (kwml, pillars) =>
        _high(kwml[Archetype.king]!) &&
        _high(pillars[Pillar.will]!) &&
        _low(kwml[Archetype.lover]!) &&
        _low(pillars[Pillar.silent]!),
  ),
  ActivePattern(
    id: 'people_pleaser',
    nameEn: 'People Pleaser',
    nameRu: 'Угодник',
    descEn: 'Connection at the cost of self. Love without boundaries.',
    descRu: 'Связь ценой себя. Любовь без границ.',
    icon: '~',
    condition: (kwml, pillars) =>
        _high(kwml[Archetype.lover]!) &&
        _low(kwml[Archetype.warrior]!) &&
        _low(pillars[Pillar.dare]!),
  ),
  ActivePattern(
    id: 'balanced',
    nameEn: 'Inner Balance',
    nameRu: 'Внутренний баланс',
    descEn: 'Harmony across all dimensions. A rare and precious state.',
    descRu: 'Гармония во всех измерениях. Редкое и ценное состояние.',
    icon: '*',
    condition: (kwml, pillars) {
      final allScores = [...kwml.values, ...pillars.values];
      final avg = allScores.reduce((a, b) => a + b) / allScores.length;
      return allScores.every((v) => (v - avg).abs() < 15) && avg >= 45;
    },
  ),
  ActivePattern(
    id: 'spiritual_bypass',
    nameEn: 'Spiritual Bypass',
    nameRu: 'Духовный обход',
    descEn: 'Using silence and knowing to avoid emotional engagement.',
    descRu: 'Использование молчания и знания для избегания эмоций.',
    icon: '?',
    condition: (kwml, pillars) =>
        _high(pillars[Pillar.know]!) &&
        _high(pillars[Pillar.silent]!) &&
        _low(kwml[Archetype.lover]!) &&
        _low(pillars[Pillar.dare]!),
  ),
];
