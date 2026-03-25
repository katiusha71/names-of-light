import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/codes_provider.dart';
import '../models/archetype.dart';
import '../models/user_profile.dart';
import '../data/questionnaire_data.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _controller = PageController();
  final List<int> _answers = List.filled(questionnaireQuestions.length, 0);
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectAnswer(int questionIndex, int rating) {
    setState(() {
      _answers[questionIndex] = rating;
    });

    // Auto-advance after short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (questionIndex < questionnaireQuestions.length - 1) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _finish() {
    // Calculate scores from answers
    // KWML: 3 questions each, average * 20 -> 0-100
    // Pillars: 2 questions each, average * 20 -> 0-100

    final kwmlScores = <Archetype, List<int>>{
      for (var a in Archetype.values) a: [],
    };
    final pillarScores = <Pillar, List<int>>{
      for (var p in Pillar.values) p: [],
    };

    for (int i = 0; i < questionnaireQuestions.length; i++) {
      final q = questionnaireQuestions[i];
      final answer = _answers[i];
      if (answer == 0) continue; // unanswered

      if (q.targetType == QuestionTarget.archetype && q.archetype != null) {
        kwmlScores[q.archetype!]!.add(answer);
      } else if (q.targetType == QuestionTarget.pillar && q.pillar != null) {
        pillarScores[q.pillar!]!.add(answer);
      }
    }

    final kwml = <Archetype, double>{};
    for (final a in Archetype.values) {
      final list = kwmlScores[a]!;
      if (list.isEmpty) {
        kwml[a] = 50.0;
      } else {
        final avg = list.reduce((a, b) => a + b) / list.length;
        kwml[a] = (avg * 20).clamp(0.0, 100.0);
      }
    }

    final pillars = <Pillar, double>{};
    for (final p in Pillar.values) {
      final list = pillarScores[p]!;
      if (list.isEmpty) {
        pillars[p] = 50.0;
      } else {
        final avg = list.reduce((a, b) => a + b) / list.length;
        pillars[p] = (avg * 20).clamp(0.0, 100.0);
      }
    }

    final profile = UserProfile(kwml: kwml, pillars: pillars);
    final provider = context.read<CodesProvider>();
    provider.setProfile(profile);
    provider.setQuestionnaireCompleted(true);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isRu = context.read<CodesProvider>().isRussian;
    final total = questionnaireQuestions.length;
    final progress = (_currentPage + 1) / total;
    final allAnswered = !_answers.contains(0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white.withAlpha(180)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isRu ? 'Диагностика' : 'Diagnostic',
          style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentPage + 1}/$total',
                style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withAlpha(15),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF6B8EFF)),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Question cards
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: total,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final q = questionnaireQuestions[index];
                return _buildQuestionCard(q, index, isRu);
              },
            ),
          ),

          // Finish button (shown on last page when all answered)
          if (_currentPage == total - 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: allAnswered ? _finish : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allAnswered
                        ? const Color(0xFF6B8EFF)
                        : const Color(0xFF1A1A3A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: const Color(0xFF1A1A3A),
                    disabledForegroundColor: Colors.white.withAlpha(60),
                  ),
                  child: Text(
                    isRu ? 'Завершить' : 'Finish',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionItem q, int index, bool isRu) {
    final selected = _answers[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question category indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              q.targetType == QuestionTarget.archetype
                  ? '${q.archetype!.icon} ${q.archetype!.getName(isRu)}'
                  : '${q.pillar!.getName(isRu)} (${q.pillar!.latinName})',
              style: TextStyle(
                color: Colors.white.withAlpha(100),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Question text
          Text(
            q.getText(isRu),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),

          // Rating buttons 1-5
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final rating = i + 1;
              final isSelected = selected == rating;
              final labels = isRu
                  ? ['Нет', '', 'Средне', '', 'Да']
                  : ['No', '', 'Neutral', '', 'Yes'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => _selectAnswer(index, rating),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6B8EFF)
                              : const Color(0xFF1A1A3A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6B8EFF)
                                : Colors.white.withAlpha(20),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$rating',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withAlpha(150),
                              fontSize: 18,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[i],
                        style: TextStyle(
                          color: Colors.white.withAlpha(60),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
