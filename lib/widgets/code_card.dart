import 'package:flutter/material.dart';
import '../models/code_item.dart';
import '../providers/codes_provider.dart';
import 'glow_painter.dart';
import 'hebrew_letter_span.dart';

class CodeCard extends StatefulWidget {
  final CodeItem item;
  final bool isFavorite;
  final bool isRussian;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final CodesProvider provider;

  const CodeCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.isRussian,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.provider,
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

  void _showColorPicker() {
    final provider = widget.provider;
    final codeId = widget.item.id;
    final currentColor = provider.getCodeColor(codeId);
    final defaultColor = widget.item.color;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ColorPickerSheet(
        currentColor: currentColor,
        defaultColor: defaultColor,
        hasOverride: provider.hasColorOverride(codeId),
        isRu: widget.isRussian,
        onSelect: (color) {
          provider.setCodeColor(codeId, color);
          Navigator.pop(ctx);
        },
        onReset: () {
          provider.resetCodeColor(codeId);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.provider.getCodeColor(widget.item.id);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: _showColorPicker,
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
                    color: color.withAlpha(_isHovered ? 120 : 40),
                    width: 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: color.withAlpha(80),
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
                            color: color,
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
                                  color: color,
                                  isRussian: widget.isRussian,
                                  shadows: [
                                    Shadow(
                                      color: color,
                                      blurRadius: 6,
                                    ),
                                    Shadow(
                                      color: color.withAlpha(180),
                                      blurRadius: 18,
                                    ),
                                    Shadow(
                                      color: color.withAlpha(100),
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

class _ColorPickerSheet extends StatelessWidget {
  final Color currentColor;
  final Color defaultColor;
  final bool hasOverride;
  final bool isRu;
  final ValueChanged<Color> onSelect;
  final VoidCallback onReset;

  const _ColorPickerSheet({
    required this.currentColor,
    required this.defaultColor,
    required this.hasOverride,
    required this.isRu,
    required this.onSelect,
    required this.onReset,
  });

  static const _palette = [
    Color(0xFFE57373), // red
    Color(0xFFFF8A65), // deep orange
    Color(0xFFFFB74D), // orange
    Color(0xFFFFD54F), // amber
    Color(0xFFFFF176), // yellow
    Color(0xFFAED581), // light green
    Color(0xFF81C784), // green
    Color(0xFF4DB6AC), // teal
    Color(0xFF4FC3F7), // light blue
    Color(0xFF64B5F6), // blue
    Color(0xFF7986CB), // indigo
    Color(0xFF9575CD), // deep purple
    Color(0xFFBA68C8), // purple
    Color(0xFFF06292), // pink
    Color(0xFFE0E0E0), // grey light
    Color(0xFF90A4AE), // blue grey
    Color(0xFFFFAB91), // peach
    Color(0xFFCE93D8), // lilac
    Color(0xFF80DEEA), // cyan
    Color(0xFFA5D6A7), // mint
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRu ? 'Цвет кода' : 'Code color',
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasOverride)
                TextButton(
                  onPressed: onReset,
                  child: Text(
                    isRu ? 'Сбросить' : 'Reset',
                    style: TextStyle(
                      color: Colors.white.withAlpha(120),
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _palette.map((c) {
              final isSelected = _colorsClose(c, currentColor);
              return GestureDetector(
                onTap: () => onSelect(c),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : Border.all(color: Colors.white.withAlpha(30)),
                    boxShadow: isSelected
                        ? [BoxShadow(color: c.withAlpha(120), blurRadius: 8)]
                        : [],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static bool _colorsClose(Color a, Color b) {
    return (a.r - b.r).abs() < 0.02 &&
           (a.g - b.g).abs() < 0.02 &&
           (a.b - b.b).abs() < 0.02;
  }
}
