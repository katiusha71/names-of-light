import 'package:flutter/material.dart';
import '../models/combination_item.dart';
import '../models/code_item.dart';
import 'glow_painter.dart';
import 'hebrew_letter_span.dart';

/// Maps icon string names from JSON to Material Icons.
IconData mapCombinationIcon(String name) {
  switch (name) {
    case 'gavel':
      return Icons.gavel;
    case 'self_improvement':
      return Icons.self_improvement;
    case 'healing':
      return Icons.healing;
    case 'monetization_on':
      return Icons.monetization_on;
    case 'favorite':
      return Icons.favorite;
    case 'shield':
      return Icons.shield;
    case 'trending_up':
      return Icons.trending_up;
    case 'work':
      return Icons.work;
    case 'family_restroom':
      return Icons.family_restroom;
    case 'auto_awesome':
      return Icons.auto_awesome;
    case 'spa':
      return Icons.spa;
    case 'volunteer_activism':
      return Icons.volunteer_activism;
    case 'child_friendly':
      return Icons.child_friendly;
    case 'flight':
      return Icons.flight;
    case 'school':
      return Icons.school;
    case 'link_off':
      return Icons.link_off;
    case 'nights_stay':
      return Icons.nights_stay;
    case 'wb_sunny':
      return Icons.wb_sunny;
    case 'bedtime':
      return Icons.bedtime;
    default:
      return Icons.auto_awesome;
  }
}

class CombinationCard extends StatefulWidget {
  final CombinationItem combination;
  final List<CodeItem> codes;
  final bool isRussian;
  final VoidCallback onTap;

  const CombinationCard({
    super.key,
    required this.combination,
    required this.codes,
    required this.isRussian,
    required this.onTap,
  });

  @override
  State<CombinationCard> createState() => _CombinationCardState();
}

class _CombinationCardState extends State<CombinationCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    if (widget.codes.isEmpty) return Colors.white;
    return widget.codes.first.color;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return AnimatedScale(
              scale: _isHovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF12122A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _accentColor.withAlpha(_isHovered ? 120 : 40),
                    width: 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: _accentColor.withAlpha(80),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: GlowPainter(
                            color: _accentColor,
                            opacity: _isHovered
                                ? _glowAnimation.value * 1.0
                                : _glowAnimation.value * 0.3,
                            radius: _isHovered ? 1.3 : 1.0,
                          ),
                        ),
                      ),
                      if (widget.combination.isCustom)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(
                            Icons.edit_note,
                            size: 14,
                            color: Colors.white.withAlpha(60),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final smallFont =
                                (constraints.maxHeight * 0.08).clamp(8.0, 11.0);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  mapCombinationIcon(widget.combination.icon),
                                  color: _accentColor.withAlpha(200),
                                  size: 22,
                                ),
                                const SizedBox(height: 6),
                                // Mini Hebrew letter preview
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: widget.codes
                                      .take(3)
                                      .map((code) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: HebrewLetterRow(
                                              letters: code.letters,
                                              fontSize: 14,
                                              color: code.color,
                                              isRussian: widget.isRussian,
                                              shadows: [
                                                Shadow(
                                                  color: code.color,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.combination.getName(widget.isRussian),
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: smallFont,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.codes.length} ${widget.isRussian ? "кодов" : "codes"}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(80),
                                    fontSize: smallFont * 0.85,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
