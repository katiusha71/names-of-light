import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/codes_provider.dart';
import '../models/archetype.dart';
import '../models/sephira_item.dart';
import '../data/pair_compatibility.dart';
import 'meditation_screen.dart';

class PairScreen extends StatelessWidget {
  const PairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CodesProvider>(
      builder: (context, provider, _) {
        final isRu = provider.isRussian;
        final d1 = provider.pairDate1;
        final d2 = provider.pairDate2;
        final reading = provider.pairReading;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? constraints.maxWidth * 0.15 : 16,
                vertical: 16,
              ),
              child: Column(
                children: [
                  // Title
                  Text(
                    isRu ? 'Совместимость пары' : 'Pair Compatibility',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRu
                        ? 'Анализ Древа Жизни на сегодня'
                        : 'Tree of Life analysis for today',
                    style: TextStyle(
                      color: Colors.white.withAlpha(80),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Two date inputs side by side on desktop, stacked on mobile
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          child: _DateInput(
                            label: isRu ? 'Партнёр 1' : 'Person 1',
                            date: d1,
                            isRu: isRu,
                            onTap: () => _pickDate(context, provider, 1),
                            onClear: d1 != null
                                ? () => provider.setPairDate1(null)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateInput(
                            label: isRu ? 'Партнёр 2' : 'Person 2',
                            date: d2,
                            isRu: isRu,
                            onTap: () => _pickDate(context, provider, 2),
                            onClear: d2 != null
                                ? () => provider.setPairDate2(null)
                                : null,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _DateInput(
                      label: isRu ? 'Партнёр 1' : 'Person 1',
                      date: d1,
                      isRu: isRu,
                      onTap: () => _pickDate(context, provider, 1),
                      onClear: d1 != null
                          ? () => provider.setPairDate1(null)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    _DateInput(
                      label: isRu ? 'Партнёр 2' : 'Person 2',
                      date: d2,
                      isRu: isRu,
                      onTap: () => _pickDate(context, provider, 2),
                      onClear: d2 != null
                          ? () => provider.setPairDate2(null)
                          : null,
                    ),
                  ],

                  // Empty state
                  if (reading == null) ...[
                    const SizedBox(height: 60),
                    Icon(
                      Icons.people_outline,
                      color: Colors.white.withAlpha(30),
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isRu
                          ? 'Укажите даты рождения обоих партнёров'
                          : 'Enter both birth dates to see compatibility',
                      style: TextStyle(
                        color: Colors.white.withAlpha(60),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Results
                  if (reading != null) ...[
                    const SizedBox(height: 24),
                    _HarmonyScoreCard(reading: reading, isRu: isRu),
                    const SizedBox(height: 12),
                    _ContactAdviceCard(reading: reading, isRu: isRu),
                    const SizedBox(height: 16),

                    // Info rows in a card
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: _InitiatorCard(
                              reading: reading,
                              isRu: isRu,
                              d1: d1!,
                              d2: d2!,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SupportCard(
                              reading: reading,
                              isRu: isRu,
                              d1: d1,
                              d2: d2,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _InitiatorCard(
                        reading: reading,
                        isRu: isRu,
                        d1: d1!,
                        d2: d2!,
                      ),
                      const SizedBox(height: 8),
                      _SupportCard(
                        reading: reading,
                        isRu: isRu,
                        d1: d1,
                        d2: d2,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Bridge & Tension
                    _BridgeTensionRow(
                      reading: reading,
                      isRu: isRu,
                      provider: provider,
                    ),
                    const SizedBox(height: 16),

                    // Archetype match
                    _ArchetypeMatchCard(
                      reading: reading,
                      isRu: isRu,
                      provider: provider,
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickDate(
      BuildContext context, CodesProvider provider, int which) async {
    final current = which == 1 ? provider.pairDate1 : provider.pairDate2;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFAA88FF),
              surface: Color(0xFF12122A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (which == 1) {
        provider.setPairDate1(picked);
      } else {
        provider.setPairDate2(picked);
      }
    }
  }
}

// === Date Input Widget ===
class _DateInput extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isRu;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateInput({
    required this.label,
    required this.date,
    required this.isRu,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF12122A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? const Color(0xFFAA88FF).withAlpha(50)
                : Colors.white.withAlpha(15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cake_outlined,
              color: const Color(0xFFAA88FF).withAlpha(180),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withAlpha(100),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (date != null)
                    Text(
                      '${date!.day.toString().padLeft(2, '0')}.${date!.month.toString().padLeft(2, '0')}.${date!.year}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      isRu ? 'указать дату рождения...' : 'set birth date...',
                      style: TextStyle(
                        color: Colors.white.withAlpha(40),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                      Icons.close, color: Colors.white.withAlpha(60), size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// === Harmony Score ===
class _HarmonyScoreCard extends StatelessWidget {
  final PairReading reading;
  final bool isRu;

  const _HarmonyScoreCard({required this.reading, required this.isRu});

  @override
  Widget build(BuildContext context) {
    final color = _harmonyColor(reading.harmonyScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Text(
            '${reading.harmonyScore}',
            style: TextStyle(
              color: color,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isRu ? 'ГАРМОНИЯ СЕГОДНЯ' : 'HARMONY TODAY',
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// === Contact Advice ===
class _ContactAdviceCard extends StatelessWidget {
  final PairReading reading;
  final bool isRu;

  const _ContactAdviceCard({required this.reading, required this.isRu});

  @override
  Widget build(BuildContext context) {
    final color = _harmonyColor(reading.harmonyScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Text(
        reading.getContactAdvice(isRu),
        style: TextStyle(
          color: Colors.white.withAlpha(220),
          fontSize: 14,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// === Who Initiates ===
class _InitiatorCard extends StatelessWidget {
  final PairReading reading;
  final bool isRu;
  final DateTime d1;
  final DateTime d2;

  const _InitiatorCard({
    required this.reading,
    required this.isRu,
    required this.d1,
    required this.d2,
  });

  @override
  Widget build(BuildContext context) {
    final String person;
    if (reading.isBalanced) {
      person = isRu ? 'Любой из двоих' : 'Either one';
    } else {
      final d = reading.firstInitiates ? d1 : d2;
      final n = reading.firstInitiates
          ? (isRu ? 'Партнёр 1' : 'Person 1')
          : (isRu ? 'Партнёр 2' : 'Person 2');
      person =
          '$n (${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')})';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B8EFF).withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(Icons.arrow_forward_rounded,
              color: const Color(0xFF6B8EFF).withAlpha(200), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRu ? 'КТО ИНИЦИИРУЕТ' : 'WHO INITIATES',
                  style: TextStyle(
                    color: Colors.white.withAlpha(80),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  person,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// === Who Needs Support ===
class _SupportCard extends StatelessWidget {
  final PairReading reading;
  final bool isRu;
  final DateTime d1;
  final DateTime d2;

  const _SupportCard({
    required this.reading,
    required this.isRu,
    required this.d1,
    required this.d2,
  });

  @override
  Widget build(BuildContext context) {
    final String person;
    if (reading.firstNeedsSupport && reading.secondNeedsSupport) {
      person = isRu ? 'Оба' : 'Both';
    } else if (reading.firstNeedsSupport) {
      person =
          '${isRu ? 'Партнёр 1' : 'Person 1'} (${d1.day.toString().padLeft(2, '0')}.${d1.month.toString().padLeft(2, '0')})';
    } else if (reading.secondNeedsSupport) {
      person =
          '${isRu ? 'Партнёр 2' : 'Person 2'} (${d2.day.toString().padLeft(2, '0')}.${d2.month.toString().padLeft(2, '0')})';
    } else {
      person = isRu ? 'Баланс — оба в силе' : 'Balanced — both strong';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF69B4).withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite_border_rounded,
              color: const Color(0xFFFF69B4).withAlpha(200), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRu ? 'КОМУ НУЖНА ПОДДЕРЖКА' : 'WHO NEEDS SUPPORT',
                  style: TextStyle(
                    color: Colors.white.withAlpha(80),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  person,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// === Bridge & Tension Row ===
class _BridgeTensionRow extends StatelessWidget {
  final PairReading reading;
  final bool isRu;
  final CodesProvider provider;

  const _BridgeTensionRow({
    required this.reading,
    required this.isRu,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final bridgeSephira = provider.getSephiraById(reading.bridgeSephiraId);
    final tensionSephira = provider.getSephiraById(reading.tensionSephiraId);

    return Row(
      children: [
        if (bridgeSephira != null)
          Expanded(
            child: _SephiraCard(
              title: isRu ? 'МОСТ' : 'BRIDGE',
              subtitle: isRu
                  ? 'Лучшая точка связи'
                  : 'Best connection point',
              sephira: bridgeSephira,
              isRu: isRu,
            ),
          ),
        if (bridgeSephira != null && tensionSephira != null)
          const SizedBox(width: 12),
        if (tensionSephira != null)
          Expanded(
            child: _SephiraCard(
              title: isRu ? 'НАПРЯЖЕНИЕ' : 'TENSION',
              subtitle: isRu
                  ? 'Зона непонимания'
                  : 'Misunderstanding zone',
              sephira: tensionSephira,
              isRu: isRu,
            ),
          ),
      ],
    );
  }
}

class _SephiraCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final SephiraItem sephira;
  final bool isRu;

  const _SephiraCard({
    required this.title,
    required this.subtitle,
    required this.sephira,
    required this.isRu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: sephira.color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sephira.color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: sephira.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sephira.getName(isRu),
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sephira.getMeaning(isRu),
            style: TextStyle(
              color: sephira.color.withAlpha(180),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withAlpha(50),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// === Archetype Match Card ===
class _ArchetypeMatchCard extends StatelessWidget {
  final PairReading reading;
  final bool isRu;
  final CodesProvider provider;

  const _ArchetypeMatchCard({
    required this.reading,
    required this.isRu,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final recommendedCode =
        provider.getCodeById(reading.archetypeResult.recommended72NameId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRu ? 'АРХЕТИПЫ ПАРЫ' : 'PAIR ARCHETYPES',
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _archetypeChip(reading.firstArchetype, isRu ? 'Партнёр 1' : 'Person 1'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white.withAlpha(60),
                    fontSize: 18,
                  ),
                ),
              ),
              _archetypeChip(reading.secondArchetype, isRu ? 'Партнёр 2' : 'Person 2'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reading.archetypeResult.getStrategy(isRu),
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 13,
              height: 1.5,
            ),
          ),

          // Recommended code
          if (recommendedCode != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        MeditationScreen(
                            item: recommendedCode, isRussian: isRu),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                          opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFAA88FF).withAlpha(12),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFFAA88FF).withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFAA88FF).withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          recommendedCode.letters,
                          style: const TextStyle(
                            color: Color(0xFFAA88FF),
                            fontSize: 15,
                            fontFamily: 'NotoSansHebrew',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRu
                                ? 'РЕКОМЕНДУЕМЫЙ КОД'
                                : 'RECOMMENDED CODE',
                            style: TextStyle(
                              color: Colors.white.withAlpha(80),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#${recommendedCode.id} — ${recommendedCode.getMeaning(isRu)}',
                            style: TextStyle(
                              color: Colors.white.withAlpha(220),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.self_improvement,
                      color: const Color(0xFFAA88FF).withAlpha(200),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _archetypeChip(Archetype archetype, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        children: [
          Text(
            archetype.icon,
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            archetype.getName(isRu),
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(60),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

Color _harmonyColor(int score) {
  if (score >= 70) return const Color(0xFF66BB6A);
  if (score >= 50) return const Color(0xFFFFD54F);
  return const Color(0xFFFF7043);
}
