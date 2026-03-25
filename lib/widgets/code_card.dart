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
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: GestureDetector(
                          onTap: _showColorPicker,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: color.withAlpha(180),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withAlpha(40),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.palette,
                              size: 9,
                              color: Colors.white.withAlpha(120),
                            ),
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

class _ColorPickerSheet extends StatefulWidget {
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

  @override
  State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late double _hue;        // 0–360
  late double _saturation; // 0–1
  late double _brightness; // 0–1

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.currentColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _brightness = hsv.value;
  }

  Color get _selectedColor =>
      HSVColor.fromAHSV(1.0, _hue, _saturation, _brightness).toColor();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isRu ? 'Цвет кода' : 'Code color',
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.hasOverride)
                    TextButton(
                      onPressed: widget.onReset,
                      child: Text(
                        widget.isRu ? 'Сбросить' : 'Reset',
                        style: TextStyle(
                          color: Colors.white.withAlpha(120),
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Saturation-Brightness field
          SizedBox(
            height: 180,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanDown: (d) => _updateSB(d.localPosition, constraints),
                  onPanUpdate: (d) => _updateSB(d.localPosition, constraints),
                  child: Stack(
                    children: [
                      // Background: hue color
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: HSVColor.fromAHSV(1, _hue, 1, 1).toColor(),
                        ),
                      ),
                      // White gradient (left to right = saturation)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.transparent],
                          ),
                        ),
                      ),
                      // Black gradient (top to bottom = brightness)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                          ),
                        ),
                      ),
                      // Selector circle
                      Positioned(
                        left: _saturation * constraints.maxWidth - 10,
                        top: (1 - _brightness) * constraints.maxHeight - 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(100),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Hue slider
          SizedBox(
            height: 28,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanDown: (d) => _updateHue(d.localPosition.dx, constraints.maxWidth),
                  onPanUpdate: (d) => _updateHue(d.localPosition.dx, constraints.maxWidth),
                  child: Stack(
                    children: [
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF0000),
                              Color(0xFFFFFF00),
                              Color(0xFF00FF00),
                              Color(0xFF00FFFF),
                              Color(0xFF0000FF),
                              Color(0xFFFF00FF),
                              Color(0xFFFF0000),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: (_hue / 360) * constraints.maxWidth - 10,
                        top: 4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: HSVColor.fromAHSV(1, _hue, 1, 1).toColor(),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(100),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Preview + Apply button
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(60)),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withAlpha(100),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onSelect(_selectedColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor.withAlpha(60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    widget.isRu ? 'Применить' : 'Apply',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateSB(Offset pos, BoxConstraints constraints) {
    setState(() {
      _saturation = (pos.dx / constraints.maxWidth).clamp(0.0, 1.0);
      _brightness = 1.0 - (pos.dy / constraints.maxHeight).clamp(0.0, 1.0);
    });
  }

  void _updateHue(double dx, double width) {
    setState(() {
      _hue = ((dx / width) * 360).clamp(0.0, 360.0);
    });
  }
}
