import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/ocr/domain/usecases/initialize_ocr.dart";
import "package:baybai/features/ocr/domain/usecases/recognize_ocr_image.dart";
import "package:baybai/features/practice/presentation/widgets/practice_bottom_sheets.dart";
import "package:baybai/features/practice/presentation/widgets/practice_drawing_canvas.dart";
import "package:baybai/features/practice/presentation/widgets/practice_drawing_controller.dart";
import "package:baybai/features/practice/presentation/widgets/practice_drawing_painter.dart";
import "package:baybai/features/practice/presentation/widgets/practice_feedback_footer.dart";
import "package:baybai/features/practice/presentation/widgets/practice_toolbar.dart";
import "package:baybai/injection_container.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";
import "dart:math" as math;
import "dart:ui" as ui;

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
    {"symbol": "\u170E", "label": "La"},
    {"symbol": "\u170F", "label": "Wa"},
    {"symbol": "\u1710", "label": "Sa"},
    {"symbol": "\u1711", "label": "Ha"},
  ];

  int _currentIndex = 0;

  late final DrawingCanvasController _drawingController;
  bool _showStrokeGuide = false;
  bool _isChecking = false;
  bool? _isPracticeCorrect;
  String? _practiceFeedback;
  Timer? _feedbackTimer;
  late final AnimationController _demoController;
  late final InitializeOcr _initializeOcr;
  late final RecognizeOcrImage _recognizeOcrImage;

  @override
  void initState() {
    super.initState();
    _drawingController = DrawingCanvasController();
    _initializeOcr = serviceLoc<InitializeOcr>();
    _recognizeOcrImage = serviceLoc<RecognizeOcrImage>();
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4400),
    );
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _demoController.dispose();
    _drawingController.dispose();
    super.dispose();
  }

  void _selectCharacterIndex(int index) {
    _currentIndex = index;
    _drawingController.resetForNewCharacter();
    _clearPracticeResult();
  }

  void _tryAgain() {
    setState(() {
      _drawingController.resetForNewCharacter();
      _clearPracticeResult();
    });
  }

  Future<void> _checkPractice() async {
    if (_isChecking) return;

    if (!_hasDrawableStroke) {
      _showTransientFeedback("Draw the character first");
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

      if (!mounted) return;
      setState(() {
        // Compare symbols while ignoring kudlit marks
        _isPracticeCorrect =
            _stripKudlits(recognized ?? '') == _stripKudlits(expected);
        _practiceFeedback = _isPracticeCorrect! ? "That's right" : "Not quite";
      });
    } catch (error) {
      debugPrint("Practice recognition error: $error");
      if (!mounted) return;
      _showTransientFeedback("Unable to check. Try again", isCorrect: false);
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _undo() {
    if (_drawingController.canUndo) {
      _drawingController.undo();
      if (_isPracticeCorrect != null) {
        setState(() {
          _clearPracticeResult();
        });
      }
    }
  }

  void _redo() {
    if (_drawingController.canRedo) {
      _drawingController.redo();
      if (_isPracticeCorrect != null) {
        setState(() {
          _clearPracticeResult();
        });
      }
    }
  }

  void _setPenMode() {
    _drawingController.setEraserMode(false);
  }

  void _setEraserMode() {
    _drawingController.setEraserMode(true);
  }

  void _changeStroke() {
    _drawingController.cycleStrokeWidth();
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
    return _drawingController.hasDrawn;
  }

  void _clearPracticeResult() {
    _feedbackTimer?.cancel();
    _feedbackTimer = null;
    _isPracticeCorrect = null;
    _practiceFeedback = null;
  }

  void _showTransientFeedback(String message, {bool? isCorrect}) {
    _feedbackTimer?.cancel();
    setState(() {
      _practiceFeedback = message;
      if (isCorrect != null) _isPracticeCorrect = isCorrect;
    });
    _feedbackTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _practiceFeedback != message) return;
      setState(() => _practiceFeedback = null);
      _feedbackTimer = null;
    });
  }

  Future<Uint8List> _renderDrawingForRecognition() async {
    final bounds = _drawingBounds();
    if (bounds == null) {
      throw StateError("No drawing to recognize.");
    }

    const double targetHeight = 192;
    const double padding = 28;
    final aspectRatio = bounds.width / math.max(bounds.height, 1);
    final targetWidth =
        (aspectRatio * (targetHeight - padding * 2) + padding * 2).clamp(
          96.0,
          512.0,
        );
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

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in _drawingController.strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(
          stroke.first.point * scale + offset,
          math.max(stroke.first.strokeWidth * scale / 2, 1),
          Paint()..color = Colors.black,
        );
        continue;
      }

      final scaledStroke = stroke
          .map(
            (sp) =>
                StrokePoint(sp.point * scale + offset, sp.strokeWidth * scale),
          )
          .toList();
      final path = PracticeDrawingPainter.buildSmoothPath(scaledStroke);
      paint.strokeWidth = math.max(stroke.first.strokeWidth * scale, 2);
      canvas.drawPath(path, paint);
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

    for (final stroke in _drawingController.strokes) {
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
    showPracticeDemonstrationSheet(
      context: context,
      controller: _demoController,
      characterLabel: _characters[_currentIndex]["label"]!,
    );
  }

  void _showSymbolPicker() {
    showPracticeSymbolPicker(
      context: context,
      characters: _characters,
      selectedIndex: _currentIndex,
      onSelect: (index) => setState(() => _selectCharacterIndex(index)),
    );
  }

  bool _isSideDrawerExpanded = true;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final character = _characters[_currentIndex];

    final navigationBarColor = isDarkMode ? AppColors.gray100 : AppColors.bg;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navigationBarColor,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 64,
          leadingWidth: 72,
          leading: const Padding(
            padding: EdgeInsets.only(left: 24.0),
            child: Center(child: CustomBackButton()),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: CustomIconButton(
                icon: Icons.grid_view_rounded,
                iconSize: 22,
                color: Colors.transparent,
                borderColor: AppColors.gray20,
                onTap: _showSymbolPicker,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Column(
                            children: [
                              PracticeToolbar(
                                listenable: _drawingController,
                                isEraserMode: () =>
                                    _drawingController.isEraserMode,
                                strokeWidth: () =>
                                    _drawingController.strokeWidth,
                                canUndo: () => _drawingController.canUndo,
                                canRedo: () => _drawingController.canRedo,
                                isDarkMode: isDarkMode,
                                showStrokeGuide: _showStrokeGuide,
                                onUndo: _undo,
                                onRedo: _redo,
                                onPen: _setPenMode,
                                onEraser: _setEraserMode,
                                onCycleStroke: _changeStroke,
                                onToggleStrokeGuide: _toggleStrokeGuide,
                                onShowDemonstration: _showDemonstrationGif,
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: PracticeDrawingCanvas(
                                  controller: _drawingController,
                                  characterSymbol: character["symbol"]!,
                                  isDarkMode: isDarkMode,
                                  showStrokeGuide: _showStrokeGuide,
                                  onDrawingStarted: () {
                                    if (_isPracticeCorrect != null) {
                                      setState(_clearPracticeResult);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildSideDrawerHandle(isDarkMode, character),
                      ],
                    ),
                  ),
                  PracticeActionFooter(
                    isCorrect: _isPracticeCorrect,
                    isChecking: _isChecking,
                    onCheck: _checkPractice,
                    onTryAgain: _tryAgain,
                  ),
                ],
              ),
              if (_practiceFeedback != null)
                Positioned(
                  bottom: 74,
                  left: 20,
                  right: 20,
                  child: PracticeFeedbackAdmonition(
                    feedback: _practiceFeedback!,
                    isCorrect: _isPracticeCorrect,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideDrawerHandle(
    bool isDarkMode,
    Map<String, String> character,
  ) {
    return Positioned(
      top: 82,
      right: 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isSideDrawerExpanded = !_isSideDrawerExpanded;
          });
        },
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 128),
          padding: _isSideDrawerExpanded
              ? const EdgeInsets.fromLTRB(16, 16, 12, 16)
              : const EdgeInsets.fromLTRB(10, 16, 8, 16),
          decoration: ShapeDecoration(
            color: AppColors.gray30,
            shape: RoundedSuperellipseBorder(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          child: _isSideDrawerExpanded
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: isDarkMode ? AppColors.gray20 : AppColors.gray100,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          character["symbol"]!,
                          style: AppTextStyles.heading.copyWith(
                            color: isDarkMode
                                ? AppColors.gray10
                                : AppColors.gray100,
                            fontSize: 72,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                  ],
                )
              : Icon(
                  Icons.chevron_left_rounded,
                  size: 24,
                  color: isDarkMode ? AppColors.gray20 : AppColors.gray100,
                ),
        ),
      ),
    );
  }
}
