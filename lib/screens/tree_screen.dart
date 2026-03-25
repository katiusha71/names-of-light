import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/codes_provider.dart';
import '../models/archetype.dart';
import '../models/sephira_item.dart';
import '../data/prescriptions_data.dart';
import '../data/daily_checkin.dart';
import '../widgets/tree_painter.dart';
import 'meditation_screen.dart';

class TreeScreen extends StatelessWidget {
  const TreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CodesProvider>(
      builder: (context, provider, _) {
        final isRu = provider.isRussian;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            if (isDesktop) {
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        if (!provider.hasBirthDate)
                          _BirthDatePrompt(provider: provider, isRu: isRu),
                        _DailyCheckinCard(provider: provider, isRu: isRu),
                        _CosmicInfoRow(provider: provider, isRu: isRu),
                        _PrescriptionsPanel(
                          prescriptions: provider.prescriptions,
                          isRu: isRu,
                          provider: provider,
                        ),
                        Expanded(
                          child: _TreeCanvas(provider: provider, isRu: isRu),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: _RightSidebar(provider: provider, isRu: isRu),
                  ),
                ],
              );
            }

            // Mobile: vertical scroll
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (!provider.hasBirthDate)
                    _BirthDatePrompt(provider: provider, isRu: isRu),
                  _DailyCheckinCard(provider: provider, isRu: isRu),
                  _CosmicInfoRow(provider: provider, isRu: isRu),
                  _PrescriptionsPanel(
                    prescriptions: provider.prescriptions,
                    isRu: isRu,
                    provider: provider,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      height: 440,
                      child: _TreeCanvas(provider: provider, isRu: isRu),
                    ),
                  ),
                  _DominantWeakestRow(provider: provider, isRu: isRu),
                  _KwmlBarsPanel(provider: provider, isRu: isRu),
                  _PillarBarsPanel(provider: provider, isRu: isRu),
                  _PatternsPanel(provider: provider, isRu: isRu),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// === Daily Check-in Card ===
class _DailyCheckinCard extends StatefulWidget {
  final CodesProvider provider;
  final bool isRu;

  const _DailyCheckinCard({required this.provider, required this.isRu});

  @override
  State<_DailyCheckinCard> createState() => _DailyCheckinCardState();
}

class _DailyCheckinCardState extends State<_DailyCheckinCard> {
  bool _isExpanded = false;
  late int _energy;
  late int _clarity;
  late int _heart;
  late int _sleep;

  @override
  void initState() {
    super.initState();
    final checkin = widget.provider.todayCheckin;
    _energy = checkin?.energy ?? 50;
    _clarity = checkin?.clarity ?? 50;
    _heart = checkin?.heart ?? 50;
    _sleep = checkin?.sleep ?? 50;
    _isExpanded = !widget.provider.hasCheckedInToday;
  }

  void _submitCheckin() {
    final checkin = DailyCheckin(
      energy: _energy,
      clarity: _clarity,
      heart: _heart,
      sleep: _sleep,
      date: DateTime.now(),
    );
    widget.provider.setDailyCheckin(checkin);
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final isRu = widget.isRu;
    final hasCheckedIn = widget.provider.hasCheckedInToday;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasCheckedIn
              ? const Color(0xFF66BB6A).withAlpha(40)
              : const Color(0xFFAA88FF).withAlpha(60),
        ),
      ),
      child: Column(
        children: [
          // Header (always visible)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    hasCheckedIn ? Icons.check_circle : Icons.self_improvement,
                    color: hasCheckedIn
                        ? const Color(0xFF66BB6A).withAlpha(200)
                        : const Color(0xFFAA88FF).withAlpha(200),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasCheckedIn
                          ? (isRu ? 'Чекин выполнен' : 'Checked in today')
                          : (isRu ? 'Дневной чекин' : 'Daily Check-in'),
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (hasCheckedIn)
                    Text(
                      '$_energy/$_clarity/$_heart/$_sleep',
                      style: TextStyle(
                        color: Colors.white.withAlpha(100),
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white.withAlpha(80),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  _buildCheckinSlider(
                    label: isRu ? 'Энергия' : 'Energy',
                    emoji: '⚡',
                    value: _energy,
                    lowLabel: isRu ? 'устал' : 'exhausted',
                    highLabel: isRu ? 'бодрый' : 'vibrant',
                    color: const Color(0xFFFF7043),
                    onChanged: (v) => setState(() => _energy = v),
                  ),
                  const SizedBox(height: 6),
                  _buildCheckinSlider(
                    label: isRu ? 'Ясность' : 'Clarity',
                    emoji: '🧠',
                    value: _clarity,
                    lowLabel: isRu ? 'туман' : 'foggy',
                    highLabel: isRu ? 'чётко' : 'sharp',
                    color: const Color(0xFF4FC3F7),
                    onChanged: (v) => setState(() => _clarity = v),
                  ),
                  const SizedBox(height: 6),
                  _buildCheckinSlider(
                    label: isRu ? 'Сердце' : 'Heart',
                    emoji: '💚',
                    value: _heart,
                    lowLabel: isRu ? 'закрыт' : 'closed',
                    highLabel: isRu ? 'открыт' : 'open',
                    color: const Color(0xFF66BB6A),
                    onChanged: (v) => setState(() => _heart = v),
                  ),
                  const SizedBox(height: 6),
                  _buildCheckinSlider(
                    label: isRu ? 'Сон' : 'Sleep',
                    emoji: '🌙',
                    value: _sleep,
                    lowLabel: isRu ? 'плохо' : 'poor',
                    highLabel: isRu ? 'отлично' : 'great',
                    color: const Color(0xFF7E57C2),
                    onChanged: (v) => setState(() => _sleep = v),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitCheckin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAA88FF).withAlpha(40),
                        foregroundColor: const Color(0xFFAA88FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(
                        hasCheckedIn
                            ? (isRu ? 'Обновить' : 'Update')
                            : (isRu ? 'Сохранить' : 'Save'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckinSlider({
    required String label,
    required String emoji,
    required int value,
    required String lowLabel,
    required String highLabel,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$value%',
              style: TextStyle(
                color: color.withAlpha(200),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              lowLabel,
              style: TextStyle(
                color: Colors.white.withAlpha(50),
                fontSize: 9,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: color,
                  inactiveTrackColor: color.withAlpha(25),
                  thumbColor: color,
                  overlayColor: color.withAlpha(30),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ),
            Text(
              highLabel,
              style: TextStyle(
                color: Colors.white.withAlpha(50),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// === Cosmic Info Row ===
class _CosmicInfoRow extends StatelessWidget {
  final CodesProvider provider;
  final bool isRu;

  const _CosmicInfoRow({required this.provider, required this.isRu});

  @override
  Widget build(BuildContext context) {
    final cosmic = provider.cosmicSummary;
    if (cosmic == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6B8EFF).withAlpha(25)),
      ),
      child: Column(
        children: [
          // Hebrew date + weekday sephira
          Row(
            children: [
              Text(
                cosmic.weekdayLetter,
                style: const TextStyle(
                  fontFamily: 'NotoSansHebrew',
                  color: Color(0xFFAA88FF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cosmic.hebrewDate.day} ${cosmic.hebrewDate.getMonthName(isRu)} ${cosmic.hebrewDate.year}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${cosmic.weekdaySephiraName} · ${cosmic.weekdayPlanet}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(100),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (cosmic.monthInfo != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B8EFF).withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${cosmic.monthInfo!.letterHe} ${cosmic.monthInfo!.getZodiac(isRu)}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(120),
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          // Omer info (if applicable)
          if (cosmic.omerText != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.grain,
                  color: const Color(0xFFFFD700).withAlpha(150),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  cosmic.omerText!,
                  style: TextStyle(
                    color: const Color(0xFFFFD700).withAlpha(180),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          // Birth date + personal sephira (if set)
          if (provider.hasBirthDate && provider.birthProfileSummary != null) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickBirthDate(context),
              child: Row(
                children: [
                  Icon(
                    Icons.cake_outlined,
                    color: const Color(0xFFAA88FF).withAlpha(120),
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${isRu ? 'Путь' : 'Path'} ${provider.birthProfileSummary!.lifePathNumber} · ${provider.birthProfileSummary!.personalSephiraName}',
                    style: TextStyle(
                      color: const Color(0xFFAA88FF).withAlpha(180),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.birthDate!.day}.${provider.birthDate!.month.toString().padLeft(2, '0')}.${provider.birthDate!.year}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(80),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    color: Colors.white.withAlpha(40),
                    size: 11,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.birthDate ?? DateTime(1990, 1, 1),
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
      provider.setBirthDate(picked);
    }
  }
}

// === Birth Date Prompt (shown when no birth date set) ===
class _BirthDatePrompt extends StatelessWidget {
  final CodesProvider provider;
  final bool isRu;

  const _BirthDatePrompt({required this.provider, required this.isRu});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickBirthDate(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A4A), Color(0xFF12122A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFAA88FF).withAlpha(60)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cake_outlined,
              color: const Color(0xFFAA88FF).withAlpha(200),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRu ? 'Укажи дату рождения' : 'Set your birth date',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isRu
                        ? 'Для персонального расчёта Древа'
                        : 'For personalized Tree calculation',
                    style: TextStyle(
                      color: Colors.white.withAlpha(100),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha(80),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
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
      provider.setBirthDate(picked);
    }
  }
}

// === Prescriptions Panel ===
class _PrescriptionsPanel extends StatelessWidget {
  final List<Prescription> prescriptions;
  final bool isRu;
  final CodesProvider provider;

  const _PrescriptionsPanel({
    required this.prescriptions,
    required this.isRu,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (prescriptions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B8EFF).withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: const Color(0xFF6B8EFF).withAlpha(180), size: 16),
              const SizedBox(width: 6),
              Text(
                isRu ? 'ДНЕВНЫЕ ПРЕДПИСАНИЯ' : 'DAILY PRESCRIPTIONS',
                style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...prescriptions.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: i < prescriptions.length - 1 ? 6 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B8EFF).withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: const Color(0xFF6B8EFF).withAlpha(200),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p.getText(isRu),
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (p.codeItem != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                MeditationScreen(
                                    item: p.codeItem!, isRussian: isRu),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            transitionDuration:
                                const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFAA88FF).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFAA88FF).withAlpha(50),
                          ),
                        ),
                        child: Icon(
                          Icons.self_improvement,
                          color: const Color(0xFFAA88FF).withAlpha(200),
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// === Tree Canvas ===
class _TreeCanvas extends StatelessWidget {
  final CodesProvider provider;
  final bool isRu;

  const _TreeCanvas({required this.provider, required this.isRu});

  @override
  Widget build(BuildContext context) {
    final visible = provider.visibleSephirot;

    return Stack(
      children: [
        // Tree canvas
        LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: TreeOfLifePainter(
                sephirot: provider.sephirot,
                weights: provider.sephiraWeights,
                showDaat: provider.showDaat,
                isRussian: isRu,
              ),
            );
          },
        ),

        // Tap overlays for each node
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return Stack(
              children: visible.map((sephira) {
                final cx = sephira.x * w;
                final cy = sephira.y * h;
                const tapSize = 44.0;
                return Positioned(
                  left: cx - tapSize / 2,
                  top: cy - tapSize / 2,
                  width: tapSize,
                  height: tapSize,
                  child: GestureDetector(
                    onTap: () => _showSephiraSheet(context, sephira, provider),
                    child: const SizedBox.expand(),
                  ),
                );
              }).toList(),
            );
          },
        ),

        // Daat toggle
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: provider.toggleDaat,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: provider.showDaat
                    ? Colors.white.withAlpha(20)
                    : const Color(0xFF1A1A3A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(30)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    provider.showDaat ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white.withAlpha(150),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isRu ? 'Даат' : 'Daat',
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSephiraSheet(
      BuildContext context, SephiraItem sephira, CodesProvider provider) {
    final isRu = provider.isRussian;
    final codes = provider.getCodesForSephira(sephira.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12122A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(60),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: sephira.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        sephira.nameHebrew,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'NotoSansHebrew',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        sephira.getName(isRu),
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Weight display
                  Row(
                    children: [
                      Text(
                        isRu ? 'Интенсивность' : 'Intensity',
                        style: TextStyle(
                          color: Colors.white.withAlpha(120),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${provider.getSephiraWeight(sephira.id).round()}%',
                        style: TextStyle(
                          color: sephira.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: provider.getSephiraWeight(sephira.id) / 100,
                      backgroundColor: sephira.color.withAlpha(30),
                      valueColor: AlwaysStoppedAnimation(sephira.color),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sephira.getDescription(isRu),
                    style: TextStyle(
                      color: Colors.white.withAlpha(160),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isRu ? 'СВЯЗАННЫЕ КОДЫ' : 'ASSOCIATED CODES',
                    style: TextStyle(
                      color: Colors.white.withAlpha(80),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...codes.map((code) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: code.color.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              code.letters,
                              style: TextStyle(
                                color: code.color,
                                fontSize: 14,
                                fontFamily: 'NotoSansHebrew',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          '#${code.id} — ${code.getMeaning(isRu)}',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          code.getCategory(isRu),
                          style: TextStyle(
                            color: Colors.white.withAlpha(100),
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  MeditationScreen(
                                      item: code, isRussian: isRu),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                            ),
                          );
                        },
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// === Right Sidebar (desktop) ===
class _RightSidebar extends StatelessWidget {
  final CodesProvider provider;
  final bool isRu;

  const _RightSidebar({required this.provider, required this.isRu});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E0E22),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _DominantWeakestRow(provider: provider, isRu: isRu),
          const SizedBox(height: 8),
          _KwmlBarsPanel(provider: provider, isRu: isRu),
          const SizedBox(height: 8),
          _PillarBarsPanel(provider: provider, isRu: isRu),
          const SizedBox(height: 8),
          _PatternsPanel(provider: provider, isRu: isRu),
        ],
      ),
    );
  }
}

// === Dominant / Weakest Row ===
class _DominantWeakestRow extends StatelessWidget {
  final CodesProvider provider;
  final bool isRu;

  const _DominantWeakestRow({required this.provider, required this.isRu});

  @override
  Widget build(BuildContext context) {
    final dom = provider.dominant;
    final weak = provider.weakest;
    if (dom == null && weak == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          if (dom != null)
            Expanded(
              child: _SephiraChip(
                label: isRu ? 'Доминантная' : 'Dominant',
                sephira: dom,
                weight: provider.getSephiraWeight(dom.id),
                isRu: isRu,
              ),
            ),
          if (dom != null && weak != null) const SizedBox(width: 8),
          if (weak != null)
            Expanded(
              child: _SephiraChip(
                label: isRu ? 'Слабейшая' : 'Weakest',
                sephira: weak,
                weight: provider.getSephiraWeight(weak.id),
                isRu: isRu,
              ),
            ),
        ],
      ),
    );
  }
}

class _SephiraChip extends StatelessWidget {
  final String label;
  final SephiraItem sephira;
  final double weight;
  final bool isRu;

  const _SephiraChip({
    required this.label,
    required this.sephira,
    required this.weight,
    required this.isRu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: sephira.color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sephira.color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: sephira.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sephira.getName(isRu),
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${weight.round()}%',
                style: TextStyle(
                  color: sephira.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// === KWML Bars Panel ===
class _KwmlBarsPanel extends StatelessWidget {
  final CodesProvider provider;
  final bool isRu;

  const _KwmlBarsPanel({required this.provider, required this.isRu});

  @override
  Widget build(BuildContext context) {
    final derived = provider.derivedKwml;
    final colors = {
      Archetype.king: const Color(0xFFFFD700),
      Archetype.warrior: const Color(0xFFFF4444),
      Archetype.magician: const Color(0xFF8B5CF6),
      Archetype.lover: const Color(0xFFFF69B4),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRu ? 'АРХЕТИПЫ KWML' : 'KWML ARCHETYPES',
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...Archetype.values.map((a) {
            final val = derived[a] ?? 50;
            final color = colors[a]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(a.icon, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 60,
                    child: Text(
                      a.getName(isRu),
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: val / 100,
                        backgroundColor: color.withAlpha(25),
                        valueColor: AlwaysStoppedAnimation(color.withAlpha(180)),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${val.round()}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: color.withAlpha(200),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// === Pillar Bars Panel ===
class _PillarBarsPanel extends StatelessWidget {
  final CodesProvider provider;
  final bool isRu;

  const _PillarBarsPanel({required this.provider, required this.isRu});

  @override
  Widget build(BuildContext context) {
    final derived = provider.derivedPillars;
    final colors = {
      Pillar.know: const Color(0xFF4FC3F7),
      Pillar.dare: const Color(0xFFFF7043),
      Pillar.will: const Color(0xFF66BB6A),
      Pillar.silent: const Color(0xFF7E57C2),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRu ? 'СТОЛПЫ' : 'PILLARS',
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...Pillar.values.map((p) {
            final val = derived[p] ?? 50;
            final color = colors[p]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      p.getName(isRu),
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: val / 100,
                        backgroundColor: color.withAlpha(25),
                        valueColor: AlwaysStoppedAnimation(color.withAlpha(180)),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${val.round()}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: color.withAlpha(200),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// === Patterns Panel ===
class _PatternsPanel extends StatelessWidget {
  final CodesProvider provider;
  final bool isRu;

  const _PatternsPanel({required this.provider, required this.isRu});

  @override
  Widget build(BuildContext context) {
    final patterns = provider.activePatterns;
    if (patterns.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRu ? 'АКТИВНЫЕ ПАТТЕРНЫ' : 'ACTIVE PATTERNS',
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...patterns.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withAlpha(15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            p.icon,
                            style: TextStyle(
                              color: Colors.white.withAlpha(120),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.getName(isRu),
                              style: TextStyle(
                                color: Colors.white.withAlpha(220),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.getDesc(isRu),
                        style: TextStyle(
                          color: Colors.white.withAlpha(120),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
