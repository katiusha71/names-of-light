import '../models/code_item.dart';

class Prescription {
  final String textEn;
  final String textRu;
  final String trigger;
  final int priority;
  final CodeItem? codeItem;

  const Prescription({
    required this.textEn,
    required this.textRu,
    required this.trigger,
    this.priority = 0,
    this.codeItem,
  });

  String getText(bool isRu) => isRu ? textRu : textEn;

  Map<String, dynamic> toJson() => {
        'textEn': textEn,
        'textRu': textRu,
        'trigger': trigger,
        'priority': priority,
      };

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        textEn: json['textEn'] as String,
        textRu: json['textRu'] as String,
        trigger: json['trigger'] as String,
        priority: json['priority'] as int? ?? 0,
      );
}

const prescriptionTemplates = <Prescription>[
  // === WEAKEST SEPHIRA ADVICE ===
  // Keter (1) - Crown / Will
  Prescription(
    textEn: 'Your crown is dim today. Spend 5 minutes in silence connecting to your highest purpose.',
    textRu: 'Твоя корона тускла сегодня. Проведи 5 минут в тишине, соединяясь с высшей целью.',
    trigger: 'weakest_1',
  ),
  Prescription(
    textEn: 'Keter calls: write down your deepest "why" before starting the day.',
    textRu: 'Кетер зовёт: запиши своё глубочайшее "зачем" перед началом дня.',
    trigger: 'weakest_1',
  ),

  // Chokmah (2) - Wisdom
  Prescription(
    textEn: 'Wisdom needs nourishment. Read or listen to something that challenges your worldview today.',
    textRu: 'Мудрость нуждается в питании. Прочти или послушай то, что бросает вызов твоему мировоззрению.',
    trigger: 'weakest_2',
  ),
  Prescription(
    textEn: 'A flash of insight awaits. Take a walk and let your mind wander without agenda.',
    textRu: 'Вспышка озарения ждёт. Прогуляйся и позволь уму блуждать без плана.',
    trigger: 'weakest_2',
  ),

  // Binah (3) - Understanding
  Prescription(
    textEn: 'Deepen understanding: take one complex topic and break it into 3 simple parts.',
    textRu: 'Углуби понимание: возьми одну сложную тему и разбей на 3 простые части.',
    trigger: 'weakest_3',
  ),
  Prescription(
    textEn: 'Binah asks for structure. Organize one area of your life or workspace today.',
    textRu: 'Бина просит структуру. Организуй одну сферу жизни или рабочее пространство сегодня.',
    trigger: 'weakest_3',
  ),

  // Daat (4) - Knowledge / Integration
  Prescription(
    textEn: 'Bridge knowing and being. Meditate on a truth you know but haven\'t embodied.',
    textRu: 'Соедини знание и бытие. Медитируй на истину, которую знаешь, но не воплотил.',
    trigger: 'weakest_4',
  ),

  // Chesed (5) - Mercy / Kindness
  Prescription(
    textEn: 'Chesed is calling: perform one act of unconditional kindness today.',
    textRu: 'Хесед зовёт: соверши один акт безусловной доброты сегодня.',
    trigger: 'weakest_5',
  ),
  Prescription(
    textEn: 'Open your heart. Reach out to someone you haven\'t spoken to in a while.',
    textRu: 'Открой сердце. Свяжись с тем, с кем давно не говорил.',
    trigger: 'weakest_5',
  ),

  // Gevurah (6) - Strength / Discipline
  Prescription(
    textEn: 'Discipline is freedom. Set one strict boundary today and honor it.',
    textRu: 'Дисциплина — это свобода. Установи одну строгую границу сегодня и соблюдай её.',
    trigger: 'weakest_6',
  ),
  Prescription(
    textEn: 'Gevurah needs exercise. Do something physically demanding within the first hour.',
    textRu: 'Гвура нуждается в упражнении. Сделай что-то физически сложное в первый час.',
    trigger: 'weakest_6',
  ),

  // Tiferet (7) - Beauty / Harmony
  Prescription(
    textEn: 'Seek beauty in the ordinary. Find one moment of harmony between opposites today.',
    textRu: 'Ищи красоту в обычном. Найди один момент гармонии между противоположностями сегодня.',
    trigger: 'weakest_7',
  ),
  Prescription(
    textEn: 'Tiferet asks for balance. Where are you leaning too far in one direction?',
    textRu: 'Тиферет просит баланса. Где ты слишком сильно склоняешься в одну сторону?',
    trigger: 'weakest_7',
  ),

  // Netzach (8) - Victory / Endurance
  Prescription(
    textEn: 'Persistence is your lesson. Continue one thing you\'ve been tempted to quit.',
    textRu: 'Настойчивость — твой урок. Продолжи одно дело, которое хотел бросить.',
    trigger: 'weakest_8',
  ),
  Prescription(
    textEn: 'Netzach energy is low. Do one creative or artistic activity to reignite passion.',
    textRu: 'Энергия Нецах низка. Займись одним творческим делом, чтобы разжечь страсть.',
    trigger: 'weakest_8',
  ),

  // Hod (9) - Splendor / Intellect
  Prescription(
    textEn: 'Hod asks for honesty. Acknowledge one thing you\'ve been avoiding intellectually.',
    textRu: 'Ход просит честности. Признай одну вещь, которую ты избегал интеллектуально.',
    trigger: 'weakest_9',
  ),
  Prescription(
    textEn: 'Sharpen your analytical mind. Study a system or framework for 15 minutes.',
    textRu: 'Оттачивай аналитический ум. Изучай систему или фреймворк 15 минут.',
    trigger: 'weakest_9',
  ),

  // Yesod (10) - Foundation
  Prescription(
    textEn: 'Your foundation needs attention. Ground yourself: feet on earth, deep breaths, presence.',
    textRu: 'Твоему основанию нужно внимание. Заземлись: ноги на земле, глубокие вдохи, присутствие.',
    trigger: 'weakest_10',
  ),
  Prescription(
    textEn: 'Yesod is the emotional root. Journal about one unprocessed feeling today.',
    textRu: 'Йесод — эмоциональный корень. Запиши в дневник одно необработанное чувство.',
    trigger: 'weakest_10',
  ),

  // Malkhut (11) - Kingdom / Manifestation
  Prescription(
    textEn: 'Manifest one intention into physical reality today, however small.',
    textRu: 'Воплоти одно намерение в физическую реальность сегодня, пусть и маленькое.',
    trigger: 'weakest_11',
  ),

  // Generic weakest
  Prescription(
    textEn: 'Your weakest sephira is asking for attention. What feels most neglected in your life?',
    textRu: 'Твоя слабейшая сефира просит внимания. Что ощущается наиболее заброшенным?',
    trigger: 'weakest_generic',
  ),

  // === DOMINANT SEPHIRA ANCHOR ===
  Prescription(
    textEn: 'Your Keter shines bright. Lead with vision and inspire others today.',
    textRu: 'Твой Кетер сияет ярко. Веди с видением и вдохновляй других сегодня.',
    trigger: 'dominant_1',
  ),
  Prescription(
    textEn: 'Chokmah is your strength. Share your wisdom — teach someone something valuable.',
    textRu: 'Хокма — твоя сила. Поделись мудростью — научи кого-то чему-то ценному.',
    trigger: 'dominant_2',
  ),
  Prescription(
    textEn: 'Binah is strong. Use your analytical power to solve a problem others have given up on.',
    textRu: 'Бина сильна. Используй аналитическую силу, чтобы решить задачу, от которой другие отказались.',
    trigger: 'dominant_3',
  ),
  Prescription(
    textEn: 'Chesed overflows. Channel your abundant kindness where it\'s most needed.',
    textRu: 'Хесед переполняет. Направь изобильную доброту туда, где она нужнее всего.',
    trigger: 'dominant_5',
  ),
  Prescription(
    textEn: 'Gevurah is your anchor. Your discipline can move mountains — choose the right mountain.',
    textRu: 'Гвура — твоя опора. Твоя дисциплина может свернуть горы — выбери правильную гору.',
    trigger: 'dominant_6',
  ),
  Prescription(
    textEn: 'Tiferet shines. You naturally harmonize opposites — bring people together today.',
    textRu: 'Тиферет сияет. Ты естественно гармонизируешь противоположности — объедини людей сегодня.',
    trigger: 'dominant_7',
  ),
  Prescription(
    textEn: 'Netzach drives you. Your endurance is admirable — use it for what truly matters.',
    textRu: 'Нецах движет тобой. Твоя выносливость восхищает — используй её для того, что действительно важно.',
    trigger: 'dominant_8',
  ),
  Prescription(
    textEn: 'Hod illuminates your mind. Your clarity can cut through confusion — help someone see.',
    textRu: 'Ход освещает твой ум. Твоя ясность может рассеять путаницу — помоги кому-то увидеть.',
    trigger: 'dominant_9',
  ),
  Prescription(
    textEn: 'Yesod is your bedrock. Your emotional stability grounds those around you.',
    textRu: 'Йесод — твоя основа. Твоя эмоциональная стабильность заземляет окружающих.',
    trigger: 'dominant_10',
  ),

  // Generic dominant
  Prescription(
    textEn: 'Your dominant sephira is your gift. Use it consciously as a force for good today.',
    textRu: 'Твоя доминантная сефира — твой дар. Используй его сознательно как силу добра сегодня.',
    trigger: 'dominant_generic',
  ),

  // === PATTERN-SPECIFIC ===
  Prescription(
    textEn: 'Slow down. Before acting, ask: "Do I understand what I\'m doing and why?"',
    textRu: 'Замедлись. Прежде чем действовать, спроси: "Понимаю ли я, что делаю и зачем?"',
    trigger: 'pattern_pseudo_productivity',
  ),
  Prescription(
    textEn: 'The Shadow King heals through listening. Ask someone for their honest opinion today.',
    textRu: 'Теневой Король исцеляется через слушание. Спроси чьё-то честное мнение сегодня.',
    trigger: 'pattern_shadow_king',
  ),
  Prescription(
    textEn: 'Burnout alert: schedule real rest. Not distraction — genuine restoration.',
    textRu: 'Предупреждение о выгорании: запланируй настоящий отдых. Не отвлечение — восстановление.',
    trigger: 'pattern_burnout_risk',
  ),
  Prescription(
    textEn: 'Pick one small action and do it NOW. You have enough information — act.',
    textRu: 'Выбери одно маленькое действие и сделай его СЕЙЧАС. У тебя достаточно информации — действуй.',
    trigger: 'pattern_analysis_paralysis',
  ),
  Prescription(
    textEn: 'Face one uncomfortable truth. Escapism dissolves when you stand firm.',
    textRu: 'Встреть одну неудобную правду. Эскапизм растворяется, когда ты стоишь твёрдо.',
    trigger: 'pattern_escapism',
  ),
  Prescription(
    textEn: 'Strength alone isn\'t enough. Reach out. Vulnerability is the highest courage.',
    textRu: 'Одной силы недостаточно. Протяни руку. Уязвимость — высшее мужество.',
    trigger: 'pattern_lone_wolf',
  ),
  Prescription(
    textEn: 'Check your motives. Are you using insight to help or to control?',
    textRu: 'Проверь свои мотивы. Ты используешь проницательность, чтобы помочь или контролировать?',
    trigger: 'pattern_trickster',
  ),
  Prescription(
    textEn: 'Dream less, do more. Ground one vision into a concrete first step today.',
    textRu: 'Мечтай меньше, делай больше. Заземли одну мечту в конкретный первый шаг сегодня.',
    trigger: 'pattern_dreamer',
  ),
  Prescription(
    textEn: 'Rules serve people, not the reverse. Find one rule to bend with compassion today.',
    textRu: 'Правила служат людям, а не наоборот. Найди одно правило, которое можно смягчить с состраданием.',
    trigger: 'pattern_rigid_order',
  ),
  Prescription(
    textEn: 'Your needs matter too. Say "no" to one request that drains you today.',
    textRu: 'Твои потребности тоже важны. Скажи "нет" одной просьбе, которая тебя истощает.',
    trigger: 'pattern_people_pleaser',
  ),
  Prescription(
    textEn: 'Beautiful balance! Maintain it by staying mindful of subtle shifts.',
    textRu: 'Прекрасный баланс! Сохраняй его, оставаясь внимательным к тонким сдвигам.',
    trigger: 'pattern_balanced',
  ),
  Prescription(
    textEn: 'Come back to the body. Spiritual growth includes feeling, not just knowing.',
    textRu: 'Вернись в тело. Духовный рост включает чувствование, а не только знание.',
    trigger: 'pattern_spiritual_bypass',
  ),

  // === ARCHETYPE-BASED (highest archetype) ===
  Prescription(
    textEn: 'Your King energy leads today — take one decisive action that moves you toward your vision.',
    textRu: 'Энергия Короля ведёт сегодня — прими одно решительное действие к своей цели.',
    trigger: 'archetype_king',
  ),
  Prescription(
    textEn: 'The King in you is strong — lead with integrity and inspire by example.',
    textRu: 'Король в тебе силён — веди с честностью и вдохновляй примером.',
    trigger: 'archetype_king',
  ),
  Prescription(
    textEn: 'Do one thing purely because you WANT to — desire is fuel, not distraction.',
    textRu: 'Сделай одну вещь просто потому, что ХОЧЕШЬ — желание это топливо, а не отвлечение.',
    trigger: 'archetype_king',
  ),
  Prescription(
    textEn: 'Warrior energy is high — channel it into disciplined focus on your hardest task.',
    textRu: 'Энергия Воина высока — направь её в дисциплинированный фокус на самую сложную задачу.',
    trigger: 'archetype_warrior',
  ),
  Prescription(
    textEn: 'Your Warrior awakens — set a bold boundary or take a courageous step today.',
    textRu: 'Твой Воин просыпается — установи смелую границу или сделай мужественный шаг.',
    trigger: 'archetype_warrior',
  ),
  Prescription(
    textEn: 'The Magician in you sees clearly — use your insight to solve what others can\'t.',
    textRu: 'Маг в тебе видит ясно — используй проницательность, чтобы решить то, что другим не под силу.',
    trigger: 'archetype_magician',
  ),
  Prescription(
    textEn: 'Magician energy peaks — study, learn, or teach something profound today.',
    textRu: 'Энергия Мага на пике — изучи, узнай или научи чему-то глубокому сегодня.',
    trigger: 'archetype_magician',
  ),
  Prescription(
    textEn: 'The Lover archetype guides you — connect deeply, create beauty, open your heart.',
    textRu: 'Архетип Любящего ведёт тебя — соединяйся глубоко, создавай красоту, открой сердце.',
    trigger: 'archetype_lover',
  ),
  Prescription(
    textEn: 'Lover energy flows — nurture one relationship or creative project with full presence.',
    textRu: 'Энергия Любящего течёт — подпитай одно отношение или проект с полным присутствием.',
    trigger: 'archetype_lover',
  ),

  // === GENERAL ===
  Prescription(
    textEn: 'Meditate on the code associated with your weakest sephira for 3 minutes.',
    textRu: 'Медитируй на код, связанный с твоей слабейшей сефирой, 3 минуты.',
    trigger: 'general',
  ),
  Prescription(
    textEn: 'Review the Tree of Life. Where does energy flow freely and where is it blocked?',
    textRu: 'Рассмотри Древо Жизни. Где энергия течёт свободно, а где заблокирована?',
    trigger: 'general',
  ),
  Prescription(
    textEn: 'Choose one 72 Name code intuitively and carry its vibration through the day.',
    textRu: 'Выбери один код 72 Имён интуитивно и неси его вибрацию через весь день.',
    trigger: 'general',
  ),
  Prescription(
    textEn: 'Balance action and rest. The middle pillar teaches equanimity.',
    textRu: 'Балансируй действие и отдых. Средний столп учит невозмутимости.',
    trigger: 'general',
  ),
  Prescription(
    textEn: 'Practice the "as above, so below" principle. Align your inner state with your outer actions.',
    textRu: 'Практикуй принцип "как вверху, так и внизу". Согласуй внутреннее состояние с внешними действиями.',
    trigger: 'general',
  ),
  Prescription(
    textEn: 'Contemplate one sephira deeply today. What does it teach about your current challenge?',
    textRu: 'Созерцай одну сефиру глубоко сегодня. Чему она учит о твоём текущем вызове?',
    trigger: 'general',
  ),
  Prescription(
    textEn: 'Notice the interplay of giving (Chesed) and receiving (Gevurah) in your day.',
    textRu: 'Замечай взаимодействие отдачи (Хесед) и получения (Гвура) в своём дне.',
    trigger: 'general',
  ),
  Prescription(
    textEn: 'The 4 Pillars of the Sphinx remind us: Know, Dare, Will, and be Silent. Which do you need most?',
    textRu: '4 Столпа Сфинкса напоминают: Знать, Дерзать, Желать и Молчать. Что тебе нужнее всего?',
    trigger: 'general',
  ),

  // === COSMIC WEEKDAY PRESCRIPTIONS ===
  Prescription(
    textEn: 'Today is ruled by Chesed — practice generosity and unconditional giving.',
    textRu: 'Сегодня правит Хесед — практикуй щедрость и безусловную отдачу.',
    trigger: 'cosmic_weekday_5',
  ),
  Prescription(
    textEn: 'Gevurah governs today. Set a firm boundary and honor it with strength.',
    textRu: 'Сегодня правит Гвура. Установи твёрдую границу и чти её с силой.',
    trigger: 'cosmic_weekday_6',
  ),
  Prescription(
    textEn: 'Tiferet leads today — seek the beauty that unites opposites around you.',
    textRu: 'Сегодня ведёт Тиферет — ищи красоту, объединяющую противоположности.',
    trigger: 'cosmic_weekday_7',
  ),
  Prescription(
    textEn: 'Netzach rules today. Persist in one creative endeavor without looking back.',
    textRu: 'Сегодня правит Нецах. Упорствуй в одном творческом деле, не оглядываясь.',
    trigger: 'cosmic_weekday_8',
  ),
  Prescription(
    textEn: 'Hod illuminates today. Speak with precision and integrity in every word.',
    textRu: 'Сегодня сияет Ход. Говори с точностью и честностью в каждом слове.',
    trigger: 'cosmic_weekday_9',
  ),
  Prescription(
    textEn: 'Yesod anchors today. Connect deeply with one person on an emotional level.',
    textRu: 'Сегодня опора — Йесод. Соединись глубоко с одним человеком на эмоциональном уровне.',
    trigger: 'cosmic_weekday_10',
  ),
  Prescription(
    textEn: 'Malkhut governs Shabbat. Ground yourself in the physical — rest, eat mindfully, be present.',
    textRu: 'Малхут правит Шаббатом. Заземлись в физическом — отдыхай, ешь осознанно, будь в моменте.',
    trigger: 'cosmic_weekday_11',
  ),

  // === OMER-SPECIFIC PRESCRIPTIONS ===
  Prescription(
    textEn: 'We are in the Omer count — refine one quality within yourself today, layer by layer.',
    textRu: 'Мы в счёте Омера — совершенствуй одно качество в себе сегодня, слой за слоем.',
    trigger: 'omer',
  ),
  Prescription(
    textEn: 'The Omer teaches sephira within sephira. Meditate on today\'s inner/outer combination.',
    textRu: 'Омер учит сефиру внутри сефиры. Медитируй на сегодняшнюю внутреннюю/внешнюю комбинацию.',
    trigger: 'omer',
  ),
  Prescription(
    textEn: 'During the Omer, each day reveals a new facet. What aspect of your character needs polishing?',
    textRu: 'Во время Омера каждый день открывает новую грань. Какой аспект твоего характера нуждается в шлифовке?',
    trigger: 'omer',
  ),
];
