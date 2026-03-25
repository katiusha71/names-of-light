import '../models/archetype.dart';

/// Compatibility matrix: user archetype + partner archetype + partner level → result
/// 4 × 4 × 2 = 32 entries
final Map<String, CompatibilityResult> archetypeMatrix = {
  // King × King
  _key(Archetype.king, Archetype.king, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 1,
    recommendedSephiraId: 1,
    strategyEn: 'Two strong leaders must learn to share the throne. Use code 1 (Keter) to align your crowns — meditate on surrendering ego while preserving authority.',
    strategyRu: 'Два сильных лидера должны научиться делить трон. Используйте код 1 (Кетер) для согласования ваших корон — медитируйте на отказ от эго при сохранении авторитета.',
  ),
  _key(Archetype.king, Archetype.king, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 8,
    recommendedSephiraId: 5,
    strategyEn: 'A weakened king needs restoration. Code 8 through Chesed brings compassionate leadership back. Guide without dominating.',
    strategyRu: 'Ослабленному королю нужно восстановление. Код 8 через Хесед возвращает сострадательное лидерство. Направляйте, не доминируя.',
  ),

  // King × Warrior
  _key(Archetype.king, Archetype.warrior, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 5,
    recommendedSephiraId: 7,
    strategyEn: 'The King directs the Warrior\'s fire. Code 5 through Tiferet balances command with courage. Channel their strength toward shared purpose.',
    strategyRu: 'Король направляет огонь Воина. Код 5 через Тиферет уравновешивает командование с мужеством. Направьте их силу к общей цели.',
  ),
  _key(Archetype.king, Archetype.warrior, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 33,
    recommendedSephiraId: 6,
    strategyEn: 'A defeated warrior needs the King\'s vision. Code 33 through Gevurah restores discipline and purpose. Offer structure, not criticism.',
    strategyRu: 'Побеждённому воину нужно видение Короля. Код 33 через Гвуру восстанавливает дисциплину и цель. Предложите структуру, а не критику.',
  ),

  // King × Magician
  _key(Archetype.king, Archetype.magician, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 9,
    recommendedSephiraId: 2,
    strategyEn: 'The King gains insight from the Magician\'s wisdom. Code 9 through Chokmah unlocks visionary strategy. Trust their knowledge, share your authority.',
    strategyRu: 'Король получает прозрение от мудрости Мага. Код 9 через Хохму открывает визионерскую стратегию. Доверяйте их знаниям, делитесь авторитетом.',
  ),
  _key(Archetype.king, Archetype.magician, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 17,
    recommendedSephiraId: 3,
    strategyEn: 'A shadow magician manipulates. Code 17 through Binah brings discernment — see through illusions while offering a path back to authentic power.',
    strategyRu: 'Теневой маг манипулирует. Код 17 через Бину приносит различение — видьте сквозь иллюзии, предлагая путь к подлинной силе.',
  ),

  // King × Lover
  _key(Archetype.king, Archetype.lover, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 41,
    recommendedSephiraId: 7,
    strategyEn: 'The King opens to the Lover\'s beauty. Code 41 through Tiferet harmonizes power with passion. Allow vulnerability to strengthen your reign.',
    strategyRu: 'Король открывается красоте Любовника. Код 41 через Тиферет гармонизирует силу со страстью. Позвольте уязвимости укрепить ваше правление.',
  ),
  _key(Archetype.king, Archetype.lover, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 65,
    recommendedSephiraId: 10,
    strategyEn: 'An addicted lover needs grounding. Code 65 through Yesod establishes healthy emotional foundations. Be the stable anchor.',
    strategyRu: 'Зависимому любовнику нужно заземление. Код 65 через Йесод устанавливает здоровые эмоциональные основы. Будьте стабильным якорем.',
  ),

  // Warrior × King
  _key(Archetype.warrior, Archetype.king, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 3,
    recommendedSephiraId: 1,
    strategyEn: 'The Warrior serves the King\'s vision. Code 3 through Keter aligns action with higher purpose. Submit to wisdom, not weakness.',
    strategyRu: 'Воин служит видению Короля. Код 3 через Кетер согласует действие с высшей целью. Подчинитесь мудрости, а не слабости.',
  ),
  _key(Archetype.warrior, Archetype.king, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 36,
    recommendedSephiraId: 6,
    strategyEn: 'A tyrannical king needs boundaries. Code 36 through Gevurah gives you the righteous strength to set limits with courage.',
    strategyRu: 'Тирану нужны границы. Код 36 через Гвуру даёт праведную силу устанавливать пределы с мужеством.',
  ),

  // Warrior × Warrior
  _key(Archetype.warrior, Archetype.warrior, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 35,
    recommendedSephiraId: 6,
    strategyEn: 'Two warriors must channel fire constructively. Code 35 through Gevurah transforms competition into alliance. Spar together, fight for each other.',
    strategyRu: 'Два воина должны направить огонь конструктивно. Код 35 через Гвуру превращает соперничество в союз. Сражайтесь вместе, друг за друга.',
  ),
  _key(Archetype.warrior, Archetype.warrior, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 49,
    recommendedSephiraId: 8,
    strategyEn: 'A broken warrior needs victory restored. Code 49 through Netzach reignites the eternal flame. Show them what endurance looks like.',
    strategyRu: 'Сломленному воину нужно восстановить победу. Код 49 через Нецах заново зажигает вечное пламя. Покажите, как выглядит стойкость.',
  ),

  // Warrior × Magician
  _key(Archetype.warrior, Archetype.magician, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 11,
    recommendedSephiraId: 2,
    strategyEn: 'The Warrior protects the Magician\'s knowledge. Code 11 through Chokmah unites action with insight. Let wisdom guide your sword.',
    strategyRu: 'Воин защищает знание Мага. Код 11 через Хохму объединяет действие с прозрением. Пусть мудрость направляет ваш меч.',
  ),
  _key(Archetype.warrior, Archetype.magician, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 57,
    recommendedSephiraId: 9,
    strategyEn: 'A trickster magician needs honesty. Code 57 through Hod brings the splendor of truth. Confront deception with clarity, not aggression.',
    strategyRu: 'Магу-обманщику нужна честность. Код 57 через Ход приносит великолепие истины. Противостойте обману ясностью, а не агрессией.',
  ),

  // Warrior × Lover
  _key(Archetype.warrior, Archetype.lover, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 44,
    recommendedSephiraId: 7,
    strategyEn: 'The Warrior softens through the Lover\'s grace. Code 44 through Tiferet balances strength with tenderness. Protect what you love.',
    strategyRu: 'Воин смягчается через грацию Любовника. Код 44 через Тиферет уравновешивает силу с нежностью. Защищайте то, что любите.',
  ),
  _key(Archetype.warrior, Archetype.lover, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 69,
    recommendedSephiraId: 10,
    strategyEn: 'An overwhelmed lover needs stability. Code 69 through Yesod builds emotional resilience. Be the shield, not the storm.',
    strategyRu: 'Подавленному любовнику нужна стабильность. Код 69 через Йесод строит эмоциональную устойчивость. Будьте щитом, а не бурей.',
  ),

  // Magician × King
  _key(Archetype.magician, Archetype.king, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 2,
    recommendedSephiraId: 1,
    strategyEn: 'The Magician advises the King. Code 2 through Keter channels supreme insight into royal decisions. Speak truth to power with grace.',
    strategyRu: 'Маг советует Королю. Код 2 через Кетер направляет высшее прозрение в королевские решения. Говорите истину власти с грацией.',
  ),
  _key(Archetype.magician, Archetype.king, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 25,
    recommendedSephiraId: 5,
    strategyEn: 'A fallen king needs wisdom, not spells. Code 25 through Chesed brings compassionate insight. Heal their crown with understanding.',
    strategyRu: 'Падшему королю нужна мудрость, а не заклинания. Код 25 через Хесед приносит сострадательное прозрение. Исцелите их корону пониманием.',
  ),

  // Magician × Warrior
  _key(Archetype.magician, Archetype.warrior, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 37,
    recommendedSephiraId: 6,
    strategyEn: 'The Magician sharpens the Warrior\'s purpose. Code 37 through Gevurah transforms raw force into precise action. Knowledge is power.',
    strategyRu: 'Маг оттачивает цель Воина. Код 37 через Гвуру превращает грубую силу в точное действие. Знание — сила.',
  ),
  _key(Archetype.magician, Archetype.warrior, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 52,
    recommendedSephiraId: 8,
    strategyEn: 'A broken warrior needs healing wisdom. Code 52 through Netzach combines knowledge with enduring hope. Teach resilience through understanding.',
    strategyRu: 'Сломленному воину нужна исцеляющая мудрость. Код 52 через Нецах сочетает знание с непреходящей надеждой. Учите стойкости через понимание.',
  ),

  // Magician × Magician
  _key(Archetype.magician, Archetype.magician, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 18,
    recommendedSephiraId: 3,
    strategyEn: 'Two magicians create powerful synergy. Code 18 through Binah deepens shared understanding. Combine your visions, multiply your insight.',
    strategyRu: 'Два мага создают мощную синергию. Код 18 через Бину углубляет совместное понимание. Объедините видения, умножьте прозрение.',
  ),
  _key(Archetype.magician, Archetype.magician, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 61,
    recommendedSephiraId: 9,
    strategyEn: 'A lost magician needs truth. Code 61 through Hod restores intellectual honesty. Help them rediscover their authentic power.',
    strategyRu: 'Потерянному магу нужна истина. Код 61 через Ход восстанавливает интеллектуальную честность. Помогите заново открыть подлинную силу.',
  ),

  // Magician × Lover
  _key(Archetype.magician, Archetype.lover, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 46,
    recommendedSephiraId: 7,
    strategyEn: 'The Magician enchants the Lover\'s world. Code 46 through Tiferet weaves beauty into wisdom. Let feeling inform your knowing.',
    strategyRu: 'Маг очаровывает мир Любовника. Код 46 через Тиферет вплетает красоту в мудрость. Пусть чувство информирует ваше знание.',
  ),
  _key(Archetype.magician, Archetype.lover, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 72,
    recommendedSephiraId: 10,
    strategyEn: 'An ungrounded lover needs wisdom\'s anchor. Code 72 through Yesod (the final code) brings completion and foundation. Transform chaos into sacred connection.',
    strategyRu: 'Незаземлённому любовнику нужен якорь мудрости. Код 72 через Йесод (последний код) приносит завершение и основу. Превратите хаос в священную связь.',
  ),

  // Lover × King
  _key(Archetype.lover, Archetype.king, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 4,
    recommendedSephiraId: 1,
    strategyEn: 'The Lover softens the King\'s crown. Code 4 through Keter opens the heart of authority. Your passion makes their vision complete.',
    strategyRu: 'Любовник смягчает корону Короля. Код 4 через Кетер открывает сердце авторитета. Ваша страсть делает их видение целостным.',
  ),
  _key(Archetype.lover, Archetype.king, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 28,
    recommendedSephiraId: 5,
    strategyEn: 'A broken king needs love\'s healing. Code 28 through Chesed pours unconditional grace. Be the heart that restores the crown.',
    strategyRu: 'Сломленному королю нужно исцеление любовью. Код 28 через Хесед изливает безусловную благодать. Будьте сердцем, восстанавливающим корону.',
  ),

  // Lover × Warrior
  _key(Archetype.lover, Archetype.warrior, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 39,
    recommendedSephiraId: 6,
    strategyEn: 'The Lover tames the Warrior\'s fire. Code 39 through Gevurah brings passionate discipline. Your warmth gives their strength meaning.',
    strategyRu: 'Любовник усмиряет огонь Воина. Код 39 через Гвуру приносит страстную дисциплину. Ваше тепло придаёт их силе смысл.',
  ),
  _key(Archetype.lover, Archetype.warrior, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 55,
    recommendedSephiraId: 8,
    strategyEn: 'A defeated warrior needs love\'s revival. Code 55 through Netzach combines eternal love with endurance. Your devotion is their victory.',
    strategyRu: 'Побеждённому воину нужно возрождение любовью. Код 55 через Нецах сочетает вечную любовь со стойкостью. Ваша преданность — их победа.',
  ),

  // Lover × Magician
  _key(Archetype.lover, Archetype.magician, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 20,
    recommendedSephiraId: 3,
    strategyEn: 'The Lover inspires the Magician\'s vision. Code 20 through Binah brings emotional depth to understanding. Feel what they think, love what they know.',
    strategyRu: 'Любовник вдохновляет видение Мага. Код 20 через Бину приносит эмоциональную глубину в понимание. Чувствуйте то, что они думают, любите то, что они знают.',
  ),
  _key(Archetype.lover, Archetype.magician, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 63,
    recommendedSephiraId: 9,
    strategyEn: 'A deceiving magician needs genuine love. Code 63 through Hod transforms illusion into authentic connection. Your truth breaks their spell.',
    strategyRu: 'Обманывающему магу нужна подлинная любовь. Код 63 через Ход превращает иллюзию в подлинную связь. Ваша истина разрушает их заклинание.',
  ),

  // Lover × Lover
  _key(Archetype.lover, Archetype.lover, ArchetypeLevel.high): const CompatibilityResult(
    recommended72NameId: 47,
    recommendedSephiraId: 7,
    strategyEn: 'Two lovers create transcendent beauty. Code 47 through Tiferet harmonizes your shared passion. Together you embody divine beauty on earth.',
    strategyRu: 'Два любовника создают трансцендентную красоту. Код 47 через Тиферет гармонизирует вашу общую страсть. Вместе вы воплощаете божественную красоту на земле.',
  ),
  _key(Archetype.lover, Archetype.lover, ArchetypeLevel.low): const CompatibilityResult(
    recommended72NameId: 67,
    recommendedSephiraId: 10,
    strategyEn: 'An addicted lover needs grounded love. Code 67 through Yesod builds a healthy emotional foundation. Love them by loving yourself first.',
    strategyRu: 'Зависимому любовнику нужна заземлённая любовь. Код 67 через Йесод строит здоровую эмоциональную основу. Любите их, сначала полюбив себя.',
  ),
};

String _key(Archetype user, Archetype partner, ArchetypeLevel level) =>
    '${user.name}_${partner.name}_${level.name}';

CompatibilityResult getCompatibility(
  Archetype userArchetype,
  Archetype partnerArchetype,
  ArchetypeLevel partnerLevel,
) {
  final key = _key(userArchetype, partnerArchetype, partnerLevel);
  return archetypeMatrix[key]!;
}
