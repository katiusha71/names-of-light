import 'package:flutter/material.dart';
import '../models/hebrew_letter.dart';

class HebrewLetterRow extends StatelessWidget {
  final String letters;
  final double fontSize;
  final Color color;
  final bool isRussian;
  final List<Shadow>? shadows;

  const HebrewLetterRow({
    super.key,
    required this.letters,
    required this.fontSize,
    required this.color,
    required this.isRussian,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final chars = letters.characters.toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: chars.map((char) {
          final info = hebrewLetters[char];
          if (info == null) {
            return Text(
              char,
              style: TextStyle(
                fontFamily: 'NotoSansHebrew',
                fontSize: fontSize,
                color: color,
                shadows: shadows,
              ),
            );
          }
          return _LetterWithTooltip(
            char: char,
            info: info,
            fontSize: fontSize,
            color: color,
            isRussian: isRussian,
            shadows: shadows,
          );
        }).toList(),
      ),
    );
  }
}

class _LetterWithTooltip extends StatefulWidget {
  final String char;
  final HebrewLetterInfo info;
  final double fontSize;
  final Color color;
  final bool isRussian;
  final List<Shadow>? shadows;

  const _LetterWithTooltip({
    required this.char,
    required this.info,
    required this.fontSize,
    required this.color,
    required this.isRussian,
    this.shadows,
  });

  @override
  State<_LetterWithTooltip> createState() => _LetterWithTooltipState();
}

class _LetterWithTooltipState extends State<_LetterWithTooltip> {
  bool _isHovered = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final isRu = widget.isRussian;
    final info = widget.info;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Invisible barrier to catch outside taps
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _removeOverlay();
                  setState(() => _isHovered = false);
                },
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            // Fixed tooltip at bottom center of screen
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14142E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.color.withAlpha(100),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withAlpha(50),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withAlpha(200),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.char,
                                style: TextStyle(
                                  fontFamily: 'NotoSansHebrew',
                                  fontSize: 40,
                                  color: widget.color,
                                  shadows: [
                                    Shadow(
                                      color: widget.color.withAlpha(150),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isRu ? info.nameRu : info.name,
                                      style: TextStyle(
                                        color: widget.color,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isRu ? info.meaningRu : info.meaning,
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(190),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            isRu ? 'Образ' : 'Symbol',
                            isRu ? info.symbolRu : info.symbol,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            isRu ? 'Функция' : 'Function',
                            isRu ? info.functionRu : info.function,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: widget.color.withAlpha(180),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _showOverlay();
        },
        onExit: (_) {
          // Small delay to allow mouse to move to the tooltip
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!_isHovered) return;
            // Only hide if overlay still exists (not already handled by overlay's onExit)
            if (_overlayEntry != null && mounted) {
              _removeOverlay();
              setState(() => _isHovered = false);
            }
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_overlayEntry != null) {
              _removeOverlay();
              setState(() => _isHovered = false);
            } else {
              setState(() => _isHovered = true);
              _showOverlay();
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.fontSize * 0.05),
            child: Text(
              widget.char,
              style: TextStyle(
                fontFamily: 'NotoSansHebrew',
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w700,
                color: _isHovered ? Colors.white : widget.color,
                shadows: _isHovered
                    ? [
                        Shadow(color: widget.color, blurRadius: 8),
                        Shadow(color: widget.color, blurRadius: 24),
                        Shadow(color: widget.color.withAlpha(180), blurRadius: 50),
                      ]
                    : widget.shadows,
              ),
            ),
          ),
        ),
    );
  }
}
