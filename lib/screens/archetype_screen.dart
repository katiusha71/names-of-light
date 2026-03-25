import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/codes_provider.dart';
import '../models/archetype.dart';
import 'questionnaire_screen.dart';

class ArchetypeScreen extends StatefulWidget {
  const ArchetypeScreen({super.key});

  @override
  State<ArchetypeScreen> createState() => _ArchetypeScreenState();
}

class _ArchetypeScreenState extends State<ArchetypeScreen> {
  final _apiKeyController = TextEditingController();
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CodesProvider>();
    _apiKeyController.text = provider.aiApiKey ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CodesProvider>(
      builder: (context, provider, _) {
        final isRu = provider.isRussian;
        final profile = provider.profile;

        final kwmlColors = {
          Archetype.king: const Color(0xFFFFD700),
          Archetype.warrior: const Color(0xFFFF4444),
          Archetype.magician: const Color(0xFF8B5CF6),
          Archetype.lover: const Color(0xFFFF69B4),
        };

        final pillarColors = {
          Pillar.know: const Color(0xFF4FC3F7),
          Pillar.dare: const Color(0xFFFF7043),
          Pillar.will: const Color(0xFF66BB6A),
          Pillar.silent: const Color(0xFF7E57C2),
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Birth Date section
              _buildBirthDateSection(provider, isRu),

              const SizedBox(height: 24),

              // Questionnaire button
              if (!provider.hasCompletedQuestionnaire)
                _buildQuestionnairePrompt(isRu)
              else
                _buildRetakeButton(isRu),

              const SizedBox(height: 24),

              // KWML Sliders
              Text(
                isRu ? 'АРХЕТИПЫ KWML' : 'KWML ARCHETYPES',
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ...Archetype.values.map((a) => _buildSlider(
                    label: '${a.icon} ${a.getName(isRu)}',
                    value: profile.kwml[a] ?? 50,
                    color: kwmlColors[a]!,
                    onChanged: (v) => provider.setKwmlScore(a, v),
                  )),

              const SizedBox(height: 24),

              // Pillar Sliders
              Text(
                isRu ? 'СТОЛПЫ СФИНКСА' : 'SPHINX PILLARS',
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ...Pillar.values.map((p) => _buildSlider(
                    label: '${p.getName(isRu)} (${p.latinName})',
                    value: profile.pillars[p] ?? 50,
                    color: pillarColors[p]!,
                    onChanged: (v) => provider.setPillarScore(p, v),
                  )),

              const SizedBox(height: 24),

              // AI API Key
              Text(
                isRu ? 'AI ПРЕДПИСАНИЯ (ОПЦИОНАЛЬНО)' : 'AI PRESCRIPTIONS (OPTIONAL)',
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRu
                    ? 'Введите API ключ для получения AI-генерированных предписаний. Без ключа используются встроенные предписания.'
                    : 'Enter API key for AI-generated prescriptions. Without a key, built-in prescriptions are used.',
                style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                obscureText: !_showApiKey,
                onChanged: (v) => provider.setAiApiKey(v.isEmpty ? null : v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(40)),
                  filled: true,
                  fillColor: const Color(0xFF1A1A3A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showApiKey ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withAlpha(80),
                      size: 18,
                    ),
                    onPressed: () => setState(() => _showApiKey = !_showApiKey),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBirthDateSection(CodesProvider provider, bool isRu) {
    final birthDate = provider.birthDate;
    final summary = provider.birthProfileSummary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A4A), Color(0xFF12122A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFAA88FF).withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cake_outlined,
                color: const Color(0xFFAA88FF).withAlpha(200),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isRu ? 'ДАТА РОЖДЕНИЯ' : 'BIRTH DATE',
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _pickBirthDate(context, provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAA88FF).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFAA88FF).withAlpha(50)),
                  ),
                  child: Text(
                    birthDate != null
                        ? '${birthDate.day}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.year}'
                        : (isRu ? 'Выбрать' : 'Select'),
                    style: TextStyle(
                      color: const Color(0xFFAA88FF).withAlpha(220),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (summary != null) ...[
            const SizedBox(height: 14),

            // Life path number + personal sephira
            Row(
              children: [
                _buildInfoChip(
                  isRu ? 'Число пути' : 'Life Path',
                  '${summary.lifePathNumber}',
                  const Color(0xFFFFD700),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  isRu ? 'Сефира' : 'Sephira',
                  summary.personalSephiraName,
                  const Color(0xFF6B8EFF),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hebrew birthday
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withAlpha(60),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  isRu ? 'Еврейский ДР: ' : 'Hebrew Birthday: ',
                  style: TextStyle(
                    color: Colors.white.withAlpha(100),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${summary.hebrewBirthday.day} ${summary.hebrewBirthday.getMonthName(isRu)}',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (summary.birthMonthInfo != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Text(
                    '${summary.birthMonthInfo!.letterHe} · ${summary.birthMonthInfo!.getZodiac(isRu)} · ${summary.birthMonthInfo!.getSense(isRu)}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(80),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withAlpha(60),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color.withAlpha(220),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBirthDate(BuildContext context, CodesProvider provider) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
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

  Widget _buildQuestionnairePrompt(bool isRu) {
    return GestureDetector(
      onTap: () => _openQuestionnaire(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A4A), Color(0xFF12122A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6B8EFF).withAlpha(60)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6B8EFF).withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                color: Color(0xFF6B8EFF),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRu ? 'Пройди диагностику' : 'Take the Diagnostic',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRu
                        ? '20 вопросов для определения твоего профиля'
                        : '20 questions to determine your profile',
                    style: TextStyle(
                      color: Colors.white.withAlpha(120),
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

  Widget _buildRetakeButton(bool isRu) {
    return OutlinedButton.icon(
      onPressed: () => _openQuestionnaire(context),
      icon: const Icon(Icons.refresh, size: 16),
      label: Text(isRu ? 'Пройти заново' : 'Retake Questionnaire'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white.withAlpha(180),
        side: BorderSide(color: Colors.white.withAlpha(30)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 13,
                ),
              ),
              Text(
                '${value.round()}',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: color,
              inactiveTrackColor: color.withAlpha(30),
              thumbColor: color,
              overlayColor: color.withAlpha(30),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _openQuestionnaire(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const QuestionnaireScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
