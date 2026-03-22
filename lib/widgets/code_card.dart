import 'package:flutter/material.dart';
import '../models/code_item.dart';
import 'glow_painter.dart';
import 'hebrew_letter_span.dart';

class CodeCard extends StatefulWidget {
  final CodeItem item;
  final bool isFavorite;
  final bool isRussian;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const CodeCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.isRussian,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  State<CodeCard> createState() => _CodeCardState();
}

class _CodeCardState extends State<CodeCard> with SingleTickerProviderStateMixin {
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
              scale: _isHovered ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF12122A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.item.color.withAlpha(_isHovered ? 120 : 40),
                    width: 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.item.color.withAlpha(80),
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
                            color: widget.item.color,
                            opacity: _isHovered
                                ? _glowAnimation.value * 1.2
                                : _glowAnimation.value * 0.5,
                            radius: _isHovered ? 1.3 : 1.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final fontSize = (constraints.maxHeight * 0.35).clamp(16.0, 36.0);
                            final smallFont = (constraints.maxHeight * 0.09).clamp(8.0, 11.0);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${widget.item.id}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(80),
                                    fontSize: smallFont,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                HebrewLetterRow(
                                  letters: widget.item.letters,
                                  fontSize: fontSize,
                                  color: widget.item.color,
                                  isRussian: widget.isRussian,
                                  shadows: [
                                    Shadow(
                                      color: widget.item.color,
                                      blurRadius: 6,
                                    ),
                                    Shadow(
                                      color: widget.item.color.withAlpha(180),
                                      blurRadius: 18,
                                    ),
                                    Shadow(
                                      color: widget.item.color.withAlpha(100),
                                      blurRadius: 35,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.item.getMeaning(widget.isRussian),
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(180),
                                    fontSize: smallFont,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: widget.onFavoriteToggle,
                          child: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 14,
                            color: widget.isFavorite
                                ? Colors.redAccent
                                : Colors.white.withAlpha(60),
                          ),
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

