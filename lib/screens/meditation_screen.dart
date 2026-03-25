import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../models/code_item.dart';
import '../providers/codes_provider.dart';
import '../widgets/glow_painter.dart';
import '../widgets/hebrew_letter_span.dart';

class _ToneOption {
  final String label;
  final String labelRu;
  final String asset;
  final int freq;

  const _ToneOption(this.label, this.labelRu, this.asset, this.freq);
}

const _tones = [
  _ToneOption('528 Hz — Healing', '528 Гц — Исцеление', 'assets/audio/tone_528.wav', 528),
  _ToneOption('432 Hz — Harmony', '432 Гц — Гармония', 'assets/audio/tone_432.wav', 432),
  _ToneOption('396 Hz — Liberation', '396 Гц — Освобождение', 'assets/audio/tone_396.wav', 396),
];

/// Maps code category to a default Solfeggio tone index.
int _defaultToneForCategory(String category) {
  switch (category) {
    // 528 Hz — Healing & Transformation
    case 'Healing':
    case 'Transformation':
    case 'Creation':
    case 'Light':
      return 0; // 528 Hz
    // 432 Hz — Harmony & Wisdom
    case 'Wisdom':
    case 'Connection':
    case 'Unity':
      return 1; // 432 Hz
    // 396 Hz — Liberation & Protection
    case 'Protection':
    case 'Abundance':
      return 2; // 396 Hz
    default:
      return 0;
  }
}

class MeditationScreen extends StatefulWidget {
  final CodeItem item;
  final bool isRussian;
  final List<CodeItem>? sequenceCodes;
  final int sequenceIndex;

  const MeditationScreen({
    super.key,
    required this.item,
    required this.isRussian,
    this.sequenceCodes,
    this.sequenceIndex = 0,
  });

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;
  late final AnimationController _glowController;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _glowRadius;
  final _focusNode = FocusNode();

  final AudioPlayer _audioPlayer = AudioPlayer();
  late int _selectedTone;
  bool _isPlaying = false;

  late int _currentIndex;
  late CodeItem _currentItem;

  bool get _hasSequence =>
      widget.sequenceCodes != null && widget.sequenceCodes!.length > 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.sequenceIndex;
    _currentItem = widget.item;
    _selectedTone = _defaultToneForCategory(_currentItem.category);

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowOpacity = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _glowRadius = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(0.5);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _breathController.dispose();
    _glowController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(AssetSource(_tones[_selectedTone].asset.replaceFirst('assets/', '')));
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _selectTone(int index) async {
    setState(() => _selectedTone = index);
    if (_isPlaying) {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(_tones[index].asset.replaceFirst('assets/', '')));
    }
  }

  void _goToCode(int index) {
    if (widget.sequenceCodes == null) return;
    if (index < 0 || index >= widget.sequenceCodes!.length) return;
    setState(() {
      _currentIndex = index;
      _currentItem = widget.sequenceCodes![index];
      _selectedTone = _defaultToneForCategory(_currentItem.category);
    });
  }

  void _nextCode() => _goToCode(_currentIndex + 1);
  void _prevCode() => _goToCode(_currentIndex - 1);

  @override
  Widget build(BuildContext context) {
    final isRu = widget.isRussian;
    final item = _currentItem;
    final color = context.watch<CodesProvider>().getCodeColor(item.id);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          } else if (event.logicalKey == LogicalKeyboardKey.space) {
            _togglePlay();
          } else if (_hasSequence &&
              event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _nextCode();
          } else if (_hasSequence &&
              event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _prevCode();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A1A),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Sequence progress indicator
                      if (_hasSequence) ...[
                        Text(
                          isRu
                              ? 'Код ${_currentIndex + 1} из ${widget.sequenceCodes!.length}'
                              : 'Code ${_currentIndex + 1} of ${widget.sequenceCodes!.length}',
                          style: TextStyle(
                            color: Colors.white.withAlpha(100),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSequenceDots(),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        item.getCategory(isRu).toUpperCase(),
                        style: TextStyle(
                          color: color.withAlpha(150),
                          fontSize: 14,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return AnimatedBuilder(
                            animation: _breathController,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: _breathAnimation.value,
                                child: SizedBox(
                                  width: 280,
                                  height: 280,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomPaint(
                                        size: const Size(280, 280),
                                        painter: GlowPainter(
                                          color: color,
                                          opacity: _glowOpacity.value,
                                          radius: _glowRadius.value,
                                        ),
                                      ),
                                      HebrewLetterRow(
                                        letters: item.letters,
                                        fontSize: 80,
                                        color: color,
                                        isRussian: isRu,
                                        shadows: [
                                          Shadow(
                                            color: color,
                                            blurRadius: 10,
                                          ),
                                          Shadow(
                                            color: color.withAlpha(220),
                                            blurRadius: 30,
                                          ),
                                          Shadow(
                                            color: color.withAlpha(150),
                                            blurRadius: 60,
                                          ),
                                          Shadow(
                                            color: color.withAlpha(80),
                                            blurRadius: 100,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Text(
                        item.getMeaning(isRu),
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Text(
                          item.getDescription(isRu),
                          style: TextStyle(
                            color: Colors.white.withAlpha(130),
                            fontSize: 15,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Sequence navigation
                      if (_hasSequence) ...[
                        _buildSequenceNavigation(isRu, color),
                        const SizedBox(height: 20),
                      ],
                      // Audio controls
                      _buildAudioControls(isRu, color),
                      const SizedBox(height: 24),
                      Text(
                        isRu
                            ? 'Дышите и медитируйте на буквы'
                            : 'Breathe and meditate on the letters',
                        style: TextStyle(
                          color: Colors.white.withAlpha(80),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hasSequence
                            ? (isRu
                                ? 'Наведите на букву для подробностей • ← → навигация • Пробел — звук'
                                : 'Hover over a letter for details • ← → navigate • Space — sound')
                            : (isRu
                                ? 'Наведите на букву для подробностей • Пробел — звук'
                                : 'Hover over a letter for details • Space — sound'),
                        style: TextStyle(
                          color: Colors.white.withAlpha(50),
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                  tooltip: isRu ? 'Назад' : 'Back',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSequenceDots() {
    final total = widget.sequenceCodes!.length;
    final prov = context.read<CodesProvider>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final code = widget.sequenceCodes![i];
        final dotColor = prov.getCodeColor(code.id);
        final isActive = i == _currentIndex;
        return GestureDetector(
          onTap: () => _goToCode(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 10 : 6,
            height: isActive ? 10 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? dotColor : dotColor.withAlpha(60),
              boxShadow: isActive
                  ? [BoxShadow(color: dotColor.withAlpha(120), blurRadius: 8)]
                  : [],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSequenceNavigation(bool isRu, Color accentColor) {
    final canPrev = _currentIndex > 0;
    final canNext = _currentIndex < widget.sequenceCodes!.length - 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: canPrev ? _prevCode : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: canPrev ? accentColor.withAlpha(15) : Colors.transparent,
              border: Border.all(
                color: canPrev
                    ? accentColor.withAlpha(80)
                    : Colors.white.withAlpha(15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 14,
                  color: canPrev
                      ? accentColor.withAlpha(200)
                      : Colors.white.withAlpha(30),
                ),
                const SizedBox(width: 4),
                Text(
                  isRu ? 'Пред.' : 'Prev',
                  style: TextStyle(
                    color: canPrev
                        ? accentColor.withAlpha(200)
                        : Colors.white.withAlpha(30),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: canNext ? _nextCode : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: canNext ? accentColor.withAlpha(15) : Colors.transparent,
              border: Border.all(
                color: canNext
                    ? accentColor.withAlpha(80)
                    : Colors.white.withAlpha(15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRu ? 'След.' : 'Next',
                  style: TextStyle(
                    color: canNext
                        ? accentColor.withAlpha(200)
                        : Colors.white.withAlpha(30),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: canNext
                      ? accentColor.withAlpha(200)
                      : Colors.white.withAlpha(30),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioControls(bool isRu, Color accentColor) {
    return Column(
      children: [
        // Play button
        GestureDetector(
          onTap: _togglePlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPlaying
                  ? accentColor.withAlpha(30)
                  : const Color(0xFF1A1A3A),
              border: Border.all(
                color: _isPlaying
                    ? accentColor.withAlpha(150)
                    : Colors.white.withAlpha(40),
                width: 1.5,
              ),
              boxShadow: _isPlaying
                  ? [
                      BoxShadow(
                        color: accentColor.withAlpha(60),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: _isPlaying ? accentColor : Colors.white.withAlpha(150),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Tone selector dropdown
        GestureDetector(
          onTap: () {
            final RenderBox button = context.findRenderObject() as RenderBox;
            final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
            showMenu<int>(
              context: context,
              color: const Color(0xFF1A1A3A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withAlpha(20)),
              ),
              position: RelativeRect.fromLTRB(
                (overlay.size.width - 220) / 2,
                button.localToGlobal(Offset.zero, ancestor: overlay).dy - _tones.length * 48,
                (overlay.size.width - 220) / 2,
                0,
              ),
              items: List.generate(_tones.length, (i) {
                final tone = _tones[i];
                return PopupMenuItem<int>(
                  value: i,
                  child: Row(
                    children: [
                      Icon(
                        _selectedTone == i
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 16,
                        color: _selectedTone == i
                            ? accentColor
                            : Colors.white.withAlpha(60),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isRu ? tone.labelRu : tone.label,
                        style: TextStyle(
                          color: _selectedTone == i
                              ? accentColor
                              : Colors.white.withAlpha(180),
                          fontSize: 13,
                          fontWeight: _selectedTone == i
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ).then((value) {
              if (value != null) _selectTone(value);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: accentColor.withAlpha(15),
              border: Border.all(color: accentColor.withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_note, size: 14, color: accentColor.withAlpha(180)),
                const SizedBox(width: 6),
                Text(
                  isRu ? _tones[_selectedTone].labelRu : _tones[_selectedTone].label,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 16, color: accentColor.withAlpha(150)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
