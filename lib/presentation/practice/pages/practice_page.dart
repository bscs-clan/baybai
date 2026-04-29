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

class _PracticePageState extends State<PracticePage> {
  final List<Map<String, String>> _characters = [
    {"symbol": "\u1700", "label": "A"},
    {"symbol": "\u170A", "label": "Ba"},
    {"symbol": "\u1703", "label": "Ka"},
    {"symbol": "\u1707", "label": "Da"},
    {"symbol": "\u1701", "label": "E/I"},
    {"symbol": "\u1704", "label": "Ga"},
    {"symbol": "\u1705", "label": "Ha"},
    {"symbol": "\u170E", "label": "La"},
    {"symbol": "\u170F", "label": "Ma"},
    {"symbol": "\u1710", "label": "Na"},
    {"symbol": "\u1705\u1714", "label": "Nga"},
    {"symbol": "\u1702", "label": "O/U"},
    {"symbol": "\u1711", "label": "Pa"},
    {"symbol": "\u1713", "label": "Sa"},
    {"symbol": "\u1714", "label": "Ta"},
    {"symbol": "\u1715", "label": "Wa"},
    {"symbol": "\u1716", "label": "Ya"},
  ];

  int _currentIndex = 0;

  final List<List<StrokePoint>> _strokes = [];
  double _strokeWidth = 4.0;
  bool _hasDrawn = false;

  void _nextCharacter() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _characters.length;
      _strokes.clear();
      _hasDrawn = false;
    });
  }

  void _previousCharacter() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _characters.length) % _characters.length;
      _strokes.clear();
      _hasDrawn = false;
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
                style: AppTextStyles.heading.copyWith(fontSize: 92),
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

                        if (!_hasDrawn)
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
                          right: 24,
                          child: Column(
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
                              const SizedBox(height: 6),
                              _buildStrokeButton(isDarkMode),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

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
              color: Colors.black,
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
