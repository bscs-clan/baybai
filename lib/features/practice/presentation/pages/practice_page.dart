import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/ocr/domain/usecases/initialize_ocr.dart";
import "package:baybai/features/ocr/domain/usecases/recognize_ocr_image.dart";
import "package:baybai/injection_container.dart";
import "package:baybai/shared/widgets/button.dart";
import "package:baybai/shared/widgets/solar_icon.dart";
import "dart:math" as math;
import "dart:typed_data";
import "dart:ui" as ui;

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
  bool _showResultButton = false;
  bool _isChecking = false;
  bool? _isPracticeCorrect;
  String? _recognizedSymbol;
  double? _recognitionConfidence;
  late final AnimationController _demoController;
  late final InitializeOcr _initializeOcr;
  late final RecognizeOcrImage _recognizeOcrImage;

  @override
  void initState() {
    super.initState();
    _initializeOcr = serviceLoc<InitializeOcr>();
    _recognizeOcrImage = serviceLoc<RecognizeOcrImage>();
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
      _showResultButton = false;
      _clearPracticeResult();
    });
  }

  void _tryAgain() {
    setState(() {
      _strokes.clear();
      _hasDrawn = false;
      _showResultButton = false;
      _clearPracticeResult();
    });
  }

  Future<void> _checkPractice() async {
    if (_isChecking) return;

    if (!_hasDrawableStroke) {
      _showToast("Please draw the character first", isError: true);
      return;
    }

    setState(() {
      _isChecking = true;
      _clearPracticeResult();
    });

    try {
      final initResult = await _initializeOcr(const NoParams());
      final initFailureMessage = initResult.fold<String?>(
        (failure) => failure.message,
        (_) => null,
      );
      if (initFailureMessage != null) {
        throw StateError(initFailureMessage);
      }

      final drawingBytes = await _renderDrawingForRecognition();
      final recognitionResult = await _recognizeOcrImage(
        RecognizeOcrImageParams(drawingBytes),
      );
      final detection = recognitionResult.fold((failure) {
        throw StateError(failure.message);
      }, (value) => value);
      final recognized = detection?.label;
      final expected = _characters[_currentIndex]["symbol"]!;
      final confidence = detection?.confidence ?? 0.0;

      if (!mounted) return;
      setState(() {
        _recognizedSymbol = recognized;
        _recognitionConfidence = confidence;
        // Compare symbols while ignoring kudlit marks
        _isPracticeCorrect =
            _stripKudlits(recognized ?? '') == _stripKudlits(expected);
        _showResultButton = true;
      });

      // Show toast notification - success only if symbols match (ignoring kudlits)
      if (_stripKudlits(recognized ?? '') == _stripKudlits(expected)) {
        _showToast("Perfect! Your drawing matched the symbol.", isError: false);
      } else {
        _showToast("Your drawing did not match. Try again!", isError: true);
      }
    } catch (error) {
      debugPrint("Practice recognition error: $error");
      if (!mounted) return;
      setState(() {
        _isPracticeCorrect = false;
        _recognizedSymbol = null;
        _recognitionConfidence = null;
        _showResultButton = false;
      });
      _showToast("Error recognizing drawing. Please try again.", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _showToast(String message, {required bool isError}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
        _hasDrawn = _strokes.isNotEmpty;
        _showResultButton = false;
        _clearPracticeResult();
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

  String _stripKudlits(String text) {
    // Remove kudlit marks (U+1712, U+1713, U+1714) which are diacritical marks
    return text.replaceAll(RegExp(r'[\u1712\u1713\u1714]'), '');
  }

  bool get _hasDrawableStroke {
    return _strokes.any((stroke) => stroke.isNotEmpty);
  }

  void _clearPracticeResult() {
    _isPracticeCorrect = null;
    _recognizedSymbol = null;
    _recognitionConfidence = null;
  }

  Future<Uint8List> _renderDrawingForRecognition() async {
    final bounds = _drawingBounds();
    if (bounds == null) {
      throw StateError("No drawing to recognize.");
    }

    const double targetHeight = 192;
    const double padding = 28;
    final aspectRatio = bounds.width / math.max(bounds.height, 1);
    final targetWidth = (aspectRatio * (targetHeight - padding * 2) +
            padding * 2)
        .clamp(96.0, 512.0);
    final scale = math.min(
      (targetWidth - padding * 2) / math.max(bounds.width, 1),
      (targetHeight - padding * 2) / math.max(bounds.height, 1),
    );
    final offset = Offset(
      (targetWidth - bounds.width * scale) / 2 - bounds.left * scale,
      (targetHeight - bounds.height * scale) / 2 - bounds.top * scale,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, targetWidth, targetHeight),
      Paint()..color = Colors.white,
    );

    final paint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(
          stroke.first.point * scale + offset,
          math.max(stroke.first.strokeWidth * scale / 2, 1),
          Paint()..color = Colors.black,
        );
        continue;
      }

      for (int i = 0; i < stroke.length - 1; i++) {
        paint.strokeWidth = math.max(stroke[i].strokeWidth * scale, 2);
        canvas.drawLine(
          stroke[i].point * scale + offset,
          stroke[i + 1].point * scale + offset,
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      targetWidth.ceil(),
      targetHeight.ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();
    if (byteData == null) {
      throw StateError("Unable to encode drawing for recognition.");
    }

    return byteData.buffer.asUint8List();
  }

  Rect? _drawingBounds() {
    double? minX;
    double? minY;
    double? maxX;
    double? maxY;

    for (final stroke in _strokes) {
      for (final strokePoint in stroke) {
        final radius = strokePoint.strokeWidth / 2;
        minX = math.min(minX ?? double.infinity, strokePoint.point.dx - radius);
        minY = math.min(minY ?? double.infinity, strokePoint.point.dy - radius);
        maxX = math.max(
          maxX ?? double.negativeInfinity,
          strokePoint.point.dx + radius,
        );
        maxY = math.max(
          maxY ?? double.negativeInfinity,
          strokePoint.point.dy + radius,
        );
      }
    }

    if (minX == null || minY == null || maxX == null || maxY == null) {
      return null;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
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
                          color:
                              isDarkMode ? AppColors.darkWhite : AppColors.text,
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
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.background,
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
                child: SolarIcon(
                  AppSolarIcons.arrowLeft,
                  size: 24,
                  color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
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
                                style: const TextStyle(
                                  fontFamily: "Baybayin",
                                  fontSize: 186,
                                  fontWeight: FontWeight.w400,
                                ).copyWith(
                                  color: (isDarkMode
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
                              _showResultButton = false;
                              _clearPracticeResult();
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
                                      color:
                                          isDarkMode
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
                                child: SolarIcon(
                                  AppSolarIcons.undo,
                                  size: 24,
                                  color:
                                      isDarkMode
                                          ? AppColors.darkIcon
                                          : AppColors.icon,
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
                                  color:
                                      _showStrokeGuide
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
                                  color:
                                      isDarkMode
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

              if (_showResultButton)
                Row(
                  children: [
                    if (_isPracticeCorrect == false)
                      Expanded(
                        child: Button(
                          label: "Try Again",
                          leftIcon: Icons.refresh,
                          onTap: _tryAgain,
                          type: ButtonType.secondary,
                        ),
                      ),
                    if (_isPracticeCorrect == true)
                      Expanded(
                        child: Button(
                          label: "Continue",
                          rightIcon: Icons.arrow_forward,
                          onTap: _nextCharacter,
                          type: ButtonType.primary,
                        ),
                      ),
                  ],
                )
              else
                Button(
                  label: _isChecking ? "Checking..." : "Check",
                  rightIcon: Icons.check,
                  onTap: _isChecking ? null : _checkPractice,
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

      final paint =
          Paint()
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
    final path =
        Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    final metric = path.computeMetrics().first;
    final drawnPath = metric.extractPath(0, metric.length * progress);
    final paint =
        Paint()
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
