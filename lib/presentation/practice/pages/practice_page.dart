import "package:flutter/material.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";
import "package:baybai/common/components/button.dart";
import "package:flutter_svg/flutter_svg.dart";

class StrokePoint {
  final Offset point;
  final double strokeWidth;

  StrokePoint(this.point, this.strokeWidth);
}

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _characters = [
    {"symbol": "\u1700", "label": "A"},
    {"symbol": "\u1701", "label": "E/I"},
    {"symbol": "\u1702", "label": "O/U"},
    {"symbol": "\u1703", "label": "Ka"},
    {"symbol": "\u1704", "label": "Ga"},
    {"symbol": "\u1705", "label": "Nga"},
    {"symbol": "\u1706", "label": "Ta"},
    {"symbol": "\u1707", "label": "Da/Ra"},
    {"symbol": "\u1708", "label": "Na"},
    {"symbol": "\u1709", "label": "Pa"},
    {"symbol": "\u170A", "label": "Ba"},
    {"symbol": "\u170B", "label": "Ma"},
    {"symbol": "\u170C", "label": "Ya"},
    {"symbol": "\u170D", "label": "La"},
    {"symbol": "\u170E", "label": "Wa"},
    {"symbol": "\u170F", "label": "Sa"},
    {"symbol": "\u1710", "label": "Ha"},
  ];

  int _currentIndex = 0;

  final List<List<StrokePoint>> _strokes = [];
  double _strokeWidth = 4.0;
  bool _hasDrawn = false;
  bool _showStrokeGuide = false;
  bool _showNavigationButtons = false;
  late final AnimationController _demoController;

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  void _nextCharacter() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _characters.length;
      _strokes.clear();
      _hasDrawn = false;
      _showNavigationButtons = false;
    });
  }

  void _previousCharacter() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _characters.length) % _characters.length;
      _strokes.clear();
      _hasDrawn = false;
      _showNavigationButtons = false;
    });
  }

  void _checkPractice() {
    setState(() {
      _showNavigationButtons = true;
    });
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
    }
  }

  void _changeStroke() {
    setState(() {
      _strokeWidth += 2;
      if (_strokeWidth > 12) _strokeWidth = 2;
    });
  }

  void _toggleStrokeGuide() {
    setState(() {
      _showStrokeGuide = !_showStrokeGuide;
    });
  }

  void _showDemonstrationGif() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final character = _characters[_currentIndex];

    _demoController
      ..reset()
      ..repeat();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.box,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Demonstration",
                        style: AppTextStyles.bigbody.copyWith(
                          color: isDarkMode
                              ? AppColors.darkWhite
                              : AppColors.text,
                        ),
                      ),
                    ),
                    _buildActionButton(
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
                      ),
                      onTap: () => Navigator.pop(dialogContext),
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _demoController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _DemoPainter(
                          symbol: character["symbol"]!,
                          progress: _demoController.value,
                          isDarkMode: isDarkMode,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(_demoController.stop);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final character = _characters[_currentIndex];

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 48,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: isDarkMode ? AppColors.darkBox : AppColors.box,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons/arrow-left.svg",
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? AppColors.darkIcon : AppColors.icon,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          "Practice",
          style: AppTextStyles.bigbody.copyWith(
            color: isDarkMode ? AppColors.darkText : AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                character["symbol"]!,
                style: AppTextStyles.heading.copyWith(
                  color: isDarkMode ? AppColors.darkWhite : AppColors.dark,
                  fontSize: 92,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: isDarkMode ? AppColors.darkBox : AppColors.box,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(38),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: Stack(
                      children: [
                        if (_showStrokeGuide)
                          IgnorePointer(
                            child: Center(
                              child: Text(
                                character["symbol"]!,
                                style:
                                    const TextStyle(
                                      fontFamily: "Baybayin",
                                      fontSize: 186,
                                      fontWeight: FontWeight.w400,
                                    ).copyWith(
                                      color:
                                          (isDarkMode
                                                  ? AppColors.white
                                                  : AppColors.dark)
                                              .withValues(alpha: 0.14),
                                    ),
                              ),
                            ),
                          ),

                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: (details) {
                            setState(() {
                              _hasDrawn = true;
                              _strokes.add([
                                StrokePoint(
                                  details.localPosition,
                                  _strokeWidth,
                                ),
                              ]);
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _strokes.last.add(
                                StrokePoint(
                                  details.localPosition,
                                  _strokeWidth,
                                ),
                              );
                            });
                          },
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _DrawPainter(_strokes, isDarkMode),
                          ),
                        ),

                        if (!_hasDrawn && !_showStrokeGuide)
                          IgnorePointer(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Draw character here",
                                    style: AppTextStyles.body.copyWith(
                                      color: isDarkMode
                                          ? AppColors.white
                                          : AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Positioned(
                          top: 24,
                          left: 24,
                          child: Row(
                            children: [
                              _buildActionButton(
                                child: SvgPicture.asset(
                                  "assets/icons/undo.svg",
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    isDarkMode
                                        ? AppColors.darkIcon
                                        : AppColors.icon,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onTap: _undo,
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(width: 6),
                              _buildStrokeButton(isDarkMode),
                              const SizedBox(width: 6),
                              _buildActionButton(
                                child: Icon(
                                  Icons.gesture,
                                  size: 22,
                                  color: _showStrokeGuide
                                      ? AppColors.primary
                                      : (isDarkMode
                                            ? AppColors.darkIcon
                                            : AppColors.icon),
                                ),
                                onTap: _toggleStrokeGuide,
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(width: 6),
                              _buildActionButton(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 24,
                                  color: isDarkMode
                                      ? AppColors.darkIcon
                                      : AppColors.icon,
                                ),
                                onTap: _showDemonstrationGif,
                                isDarkMode: isDarkMode,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              if (_showNavigationButtons)
                Row(
                  children: [
                    Expanded(
                      child: Button(
                        label: "Previous",
                        leftIcon: Icons.arrow_back,
                        onTap: _previousCharacter,
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Button(
                        label: "Next",
                        rightIcon: Icons.arrow_forward,
                        onTap: _nextCharacter,
                        type: ButtonType.primary,
                      ),
                    ),
                  ],
                )
              else
                Button(
                  label: "Check",
                  rightIcon: Icons.check,
                  onTap: _checkPractice,
                  type: ButtonType.primary,
                  width: double.infinity,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrokeButton(bool isDarkMode) {
    return GestureDetector(
      onTap: _changeStroke,
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          color: isDarkMode ? AppColors.darkCompBg : AppColors.compBg,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Center(
          child: Container(
            width: _strokeWidth * 2,
            height: _strokeWidth * 2,
            decoration: ShapeDecoration(
              color: isDarkMode ? AppColors.darkWhite : AppColors.dark,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Widget child,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          color: isDarkMode ? AppColors.darkCompBg : AppColors.compBg,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DrawPainter extends CustomPainter {
  final List<List<StrokePoint>> strokes;
  final bool isDarkMode;

  _DrawPainter(this.strokes, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      final paint = Paint()
        ..color = isDarkMode ? Colors.white : Colors.black
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < stroke.length - 1; i++) {
        paint.strokeWidth = stroke[i].strokeWidth;

        canvas.drawLine(stroke[i].point, stroke[i + 1].point, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DemoPainter extends CustomPainter {
  final String symbol;
  final double progress;
  final bool isDarkMode;

  _DemoPainter({
    required this.symbol,
    required this.progress,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final guidePainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: (isDarkMode ? AppColors.white : AppColors.dark).withValues(
            alpha: 0.12,
          ),
          fontFamily: "Baybayin",
          fontSize: 128,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    guidePainter.paint(
      canvas,
      Offset(
        (size.width - guidePainter.width) / 2,
        (size.height - guidePainter.height) / 2,
      ),
    );

    final start = Offset(size.width * 0.24, size.height * 0.76);
    final control = Offset(size.width * 0.48, size.height * 0.18);
    final end = Offset(size.width * 0.76, size.height * 0.68);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    final metric = path.computeMetrics().first;
    final drawnPath = metric.extractPath(0, metric.length * progress);
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;

    canvas.drawPath(drawnPath, paint);

    final tangent = metric.getTangentForOffset(metric.length * progress);
    if (tangent == null) return;

    canvas.drawCircle(
      tangent.position,
      9,
      Paint()..color = isDarkMode ? AppColors.darkWhite : AppColors.white,
    );
    canvas.drawCircle(tangent.position, 6, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _DemoPainter oldDelegate) {
    return oldDelegate.symbol != symbol ||
        oldDelegate.progress != progress ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
