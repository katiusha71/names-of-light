import '../models/archetype.dart';

enum QuestionTarget { archetype, pillar }

class QuestionItem {
  final String textEn;
  final String textRu;
  final QuestionTarget targetType;
  final Archetype? archetype;
  final Pillar? pillar;

  const QuestionItem({
    required this.textEn,
    required this.textRu,
    required this.targetType,
    this.archetype,
    this.pillar,
  });

  String getText(bool isRu) => isRu ? textRu : textEn;
}

const questionnaireQuestions = <QuestionItem>[
  // === KING (3 questions) ===
  QuestionItem(
    textEn: 'I naturally take charge and lead in group situations.',
    textRu: 'Я естественно беру на себя лидерство в групповых ситуациях.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.king,
  ),
  QuestionItem(
    textEn: 'I feel responsible for the well-being of those around me.',
    textRu: 'Я чувствую ответственность за благополучие окружающих.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.king,
  ),
  QuestionItem(
    textEn: 'I have a clear long-term vision for my life.',
    textRu: 'У меня есть чёткое долгосрочное видение моей жизни.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.king,
  ),

  // === WARRIOR (3 questions) ===
  QuestionItem(
    textEn: 'I maintain strict self-discipline even when no one is watching.',
    textRu: 'Я поддерживаю строгую самодисциплину, даже когда никто не наблюдает.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.warrior,
  ),
  QuestionItem(
    textEn: 'I don\'t back down from confrontation when my values are at stake.',
    textRu: 'Я не отступаю от конфронтации, когда на кону мои ценности.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.warrior,
  ),
  QuestionItem(
    textEn: 'I take decisive action even in uncertain situations.',
    textRu: 'Я принимаю решительные действия даже в неопределённых ситуациях.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.warrior,
  ),

  // === MAGICIAN (3 questions) ===
  QuestionItem(
    textEn: 'I enjoy uncovering hidden patterns and deeper meanings.',
    textRu: 'Мне нравится раскрывать скрытые паттерны и глубинные смыслы.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.magician,
  ),
  QuestionItem(
    textEn: 'I am constantly learning and expanding my knowledge.',
    textRu: 'Я постоянно учусь и расширяю свои знания.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.magician,
  ),
  QuestionItem(
    textEn: 'I can see situations from multiple perspectives simultaneously.',
    textRu: 'Я могу видеть ситуации с нескольких перспектив одновременно.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.magician,
  ),

  // === LOVER (3 questions) ===
  QuestionItem(
    textEn: 'I easily sense other people\'s emotions and needs.',
    textRu: 'Я легко чувствую эмоции и потребности других людей.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.lover,
  ),
  QuestionItem(
    textEn: 'I feel deeply passionate about my interests and relationships.',
    textRu: 'Я глубоко страстно отношусь к своим интересам и отношениям.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.lover,
  ),
  QuestionItem(
    textEn: 'I seek deep, meaningful connections with others.',
    textRu: 'Я ищу глубокие, значимые связи с другими.',
    targetType: QuestionTarget.archetype,
    archetype: Archetype.lover,
  ),

  // === KNOW / Noscere (2 questions) ===
  QuestionItem(
    textEn: 'I have a strong drive to understand how things work at a fundamental level.',
    textRu: 'У меня есть сильное стремление понять, как вещи работают на фундаментальном уровне.',
    targetType: QuestionTarget.pillar,
    pillar: Pillar.know,
  ),
  QuestionItem(
    textEn: 'I am aware of my own strengths, weaknesses, and patterns.',
    textRu: 'Я осознаю свои сильные стороны, слабости и паттерны.',
    targetType: QuestionTarget.pillar,
    pillar: Pillar.know,
  ),

  // === DARE / Audere (2 questions) ===
  QuestionItem(
    textEn: 'I regularly take risks to grow beyond my comfort zone.',
    textRu: 'Я регулярно рискую, чтобы расти за пределами зоны комфорта.',
    targetType: QuestionTarget.pillar,
    pillar: Pillar.dare,
  ),
  QuestionItem(
    textEn: 'I am bold in expressing my authentic self, even when it\'s unpopular.',
    textRu: 'Я смел в выражении своего истинного я, даже когда это непопулярно.',
    targetType: QuestionTarget.pillar,
    pillar: Pillar.dare,
  ),

  // === WILL / Velle (2 questions) ===
  QuestionItem(
    textEn: 'When I set a goal, I pursue it with unwavering determination.',
    textRu: 'Когда я ставлю цель, я преследую её с непоколебимой решимостью.',
    targetType: QuestionTarget.pillar,
    pillar: Pillar.will,
  ),
  QuestionItem(
    textEn: 'I can maintain intense focus for extended periods.',
    textRu: 'Я могу поддерживать интенсивную концентрацию в течение длительных периодов.',
    targetType: QuestionTarget.pillar,
    pillar: Pillar.will,
  ),

  // === SILENT / Tacere (2 questions) ===
  QuestionItem(
    textEn: 'I am comfortable with silence and enjoy periods of solitude.',
    textRu: 'Мне комфортно в тишине, и я наслаждаюсь периодами одиночества.',
    targetType: QuestionTarget.pillar,
    pillar: Pillar.silent,
  ),
  QuestionItem(
    textEn: 'I practice restraint — I know when NOT to speak or act.',
    textRu: 'Я практикую сдержанность — я знаю, когда НЕ говорить и НЕ действовать.',
    targetType: QuestionTarget.pillar,
    pillar: Pillar.silent,
  ),
];
