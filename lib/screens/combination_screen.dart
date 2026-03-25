import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/combination_item.dart';
import '../models/code_item.dart';
import '../providers/codes_provider.dart';
import '../widgets/glow_painter.dart';
import '../widgets/hebrew_letter_span.dart';
import '../widgets/combination_card.dart';
import 'meditation_screen.dart';
import 'create_combination_screen.dart';

class CombinationScreen extends StatelessWidget {
  final CombinationItem combination;
  final List<CodeItem> codes;
  final bool isRussian;

  const CombinationScreen({
    super.key,
    required this.combination,
    required this.codes,
    required this.isRussian,
  });

  void _startMeditation(BuildContext context) {
    if (codes.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MeditationScreen(
          item: codes.first,
          isRussian: isRussian,
          sequenceCodes: codes,
          sequenceIndex: 0,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _openSingleCode(BuildContext context, CodeItem code, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MeditationScreen(
          item: code,
          isRussian: isRussian,
          sequenceCodes: codes,
          sequenceIndex: index,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _editCombination(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreateCombinationScreen(existing: combination),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _deleteCombination(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3A),
        title: Text(
          isRussian ? 'Удалить комбинацию?' : 'Delete combination?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isRussian
              ? 'Это действие нельзя отменить.'
              : 'This action cannot be undone.',
          style: TextStyle(color: Colors.white.withAlpha(150)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isRussian ? 'Отмена' : 'Cancel',
              style: TextStyle(color: Colors.white.withAlpha(150)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context
                  .read<CodesProvider>()
                  .deleteCustomCombination(combination.id);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Icon(
                        mapCombinationIcon(combination.icon),
                        color: codes.isNotEmpty
                            ? codes.first.color.withAlpha(180)
                            : Colors.white.withAlpha(180),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        combination.getCategory(isRussian).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withAlpha(100),
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        combination.getName(isRussian),
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        combination.getDescription(isRussian),
                        style: TextStyle(
                          color: Colors.white.withAlpha(120),
                          fontSize: 14,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Start meditation button
                      GestureDetector(
                        onTap: () => _startMeditation(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: codes.isNotEmpty
                                ? codes.first.color.withAlpha(25)
                                : Colors.white.withAlpha(15),
                            border: Border.all(
                              color: codes.isNotEmpty
                                  ? codes.first.color.withAlpha(120)
                                  : Colors.white.withAlpha(40),
                            ),
                          ),
                          child: Text(
                            isRussian
                                ? 'Начать медитацию'
                                : 'Start Meditation',
                            style: TextStyle(
                              color: codes.isNotEmpty
                                  ? codes.first.color
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Code sequence
                      ...List.generate(codes.length, (index) {
                        final code = codes[index];
                        return Column(
                          children: [
                            if (index > 0)
                              _buildConnector(code.color),
                            _buildCodeTile(context, code, index),
                          ],
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white.withAlpha(120),
                ),
                tooltip: isRussian ? 'Назад' : 'Back',
              ),
            ),
          ),
          // Edit/Delete buttons for custom combinations
          if (combination.isCustom)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editCombination(context),
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.white.withAlpha(120),
                      ),
                      tooltip: isRussian ? 'Редактировать' : 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteCombination(context),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent.withAlpha(150),
                      ),
                      tooltip: isRussian ? 'Удалить' : 'Delete',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnector(Color color) {
    return Container(
      width: 2,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withAlpha(60),
            color.withAlpha(30),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeTile(BuildContext context, CodeItem code, int index) {
    return GestureDetector(
      onTap: () => _openSingleCode(context, code, index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12122A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: code.color.withAlpha(40)),
        ),
        child: Row(
          children: [
            // Step number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: code.color.withAlpha(20),
                border: Border.all(color: code.color.withAlpha(80)),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: code.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Hebrew letters with glow
            SizedBox(
              width: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(70, 40),
                    painter: GlowPainter(
                      color: code.color,
                      opacity: 0.4,
                      radius: 0.8,
                    ),
                  ),
                  HebrewLetterRow(
                    letters: code.letters,
                    fontSize: 28,
                    color: code.color,
                    isRussian: isRussian,
                    shadows: [
                      Shadow(color: code.color, blurRadius: 6),
                      Shadow(color: code.color.withAlpha(150), blurRadius: 18),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Code info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${code.id}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(60),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    code.getMeaning(isRussian),
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_outline,
              color: Colors.white.withAlpha(60),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
