import "dart:ui";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/ocr/domain/usecases/initialize_ocr.dart";
import "package:baybai/features/ocr/domain/usecases/recognize_ocr_image.dart";
import "package:baybai/features/practice/presentation/widgets/baybayin_stroke_demo.dart";
import "package:baybai/injection_container.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";
import "dart:math" as math;
import "dart:typed_data";
import "dart:ui" as ui;

class StrokePoint {
  final Offset point;
  final double strokeWidth;

  StrokePoint(this.point, this.strokeWidth);
}

class DrawingCanvasController extends ChangeNotifier {
  final List<List<StrokePoint>> _strokes = [];
  final List<List<List<StrokePoint>>> _undoHistory = [];
  final List<List<List<StrokePoint>>> _redoHistory = [];

  bool _isEraserMode = false;
  Offset? _eraserPosition;
  double _strokeWidth = 6.0;

  List<List<StrokePoint>> get strokes => _strokes;
  bool get isEraserMode => _isEraserMode;
  Offset? get eraserPosition => _eraserPosition;
  double get strokeWidth => _strokeWidth;
  bool get hasDrawn => _strokes.any((stroke) => stroke.isNotEmpty);
  bool get canUndo => _undoHistory.isNotEmpty;
  bool get canRedo => _redoHistory.isNotEmpty;

  void setEraserMode(bool enabled) {
    if (_isEraserMode != enabled) {
      _isEraserMode = enabled;
      _eraserPosition = null;
      notifyListeners();
    }
  }

  void cycleStrokeWidth() {
    _strokeWidth += 2;
    if (_strokeWidth > 12) _strokeWidth = 2;
    notifyListeners();
  }

  void resetForNewCharacter() {
    _strokes.clear();
    _undoHistory.clear();
    _redoHistory.clear();
    _isEraserMode = false;
    _eraserPosition = null;
    notifyListeners();
  }

  void _saveSnapshotForUndo() {
    _undoHistory.add(_cloneStrokes(_strokes));
    _redoHistory.clear();
  }

  List<List<StrokePoint>> _cloneStrokes(List<List<StrokePoint>> source) {
    return source.map((stroke) => List<StrokePoint>.from(stroke)).toList();
  }

  void undo() {
    if (_undoHistory.isNotEmpty) {
      _redoHistory.add(_cloneStrokes(_strokes));
      final previousState = _undoHistory.removeLast();
      _strokes
        ..clear()
        ..addAll(previousState);
      notifyListeners();
    }
  }

  void redo() {
    if (_redoHistory.isNotEmpty) {
      _undoHistory.add(_cloneStrokes(_strokes));
      final nextState = _redoHistory.removeLast();
      _strokes
        ..clear()
        ..addAll(nextState);
      notifyListeners();
    }
  }

  void startGesture(Offset point) {
    _saveSnapshotForUndo();
    if (_isEraserMode) {
      _eraserPosition = point;
      _eraseAtPoint(point);
    } else {
      _eraserPosition = null;
      _strokes.add([StrokePoint(point, _strokeWidth)]);
    }
    notifyListeners();
  }

  void updateGesture(Offset point) {
    if (_isEraserMode) {
      _eraserPosition = point;
      _eraseAtPoint(point);
      notifyListeners();
    } else {
      _eraserPosition = null;
      if (_strokes.isNotEmpty) {
        final lastStroke = _strokes.last;
        if (lastStroke.isNotEmpty) {
          final lastPoint = lastStroke.last.point;
          final distSq = (point - lastPoint).distanceSquared;
          if (distSq >= 2.25) {
            lastStroke.add(StrokePoint(point, _strokeWidth));
            notifyListeners();
          }
        } else {
          lastStroke.add(StrokePoint(point, _strokeWidth));
          notifyListeners();
        }
      }
    }
  }

  void endGesture() {
    if (_isEraserMode) {
      _eraserPosition = null;
      notifyListeners();
    }
  }

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (ab2 == 0) return (p - a).distance;
    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / ab2).clamp(0.0, 1.0);
    final projection = a + ab * t;
    return (p - projection).distance;
  }

  Rect _getStrokeBounds(List<StrokePoint> stroke) {
    double minX = stroke.first.point.dx, minY = stroke.first.point.dy;
    double maxX = stroke.first.point.dx, maxY = stroke.first.point.dy;
    for (final sp in stroke) {
      if (sp.point.dx < minX) minX = sp.point.dx;
      if (sp.point.dx > maxX) maxX = sp.point.dx;
      if (sp.point.dy < minY) minY = sp.point.dy;
      if (sp.point.dy > maxY) maxY = sp.point.dy;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  void _eraseAtPoint(Offset point) {
    const double eraseRadius = 24.0;
    List<List<StrokePoint>> newStrokes = [];
    bool erasedAny = false;

    for (final stroke in _strokes) {
      if (stroke.isEmpty) continue;

      final bounds = _getStrokeBounds(stroke);
      final maxStrokeWidth = stroke.first.strokeWidth;
      final maxEraseDist = math.max(eraseRadius, maxStrokeWidth * 1.5);

      if (!bounds.inflate(maxEraseDist + 10).contains(point)) {
        newStrokes.add(stroke);
        continue;
      }

      if (stroke.length == 1) {
        final dist = (stroke.first.point - point).distance;
        if (dist <= maxEraseDist) {
          erasedAny = true;
        } else {
          newStrokes.add(stroke);
        }
        continue;
      }

      List<StrokePoint> currentSegment = [stroke.first];
      for (int i = 0; i < stroke.length - 1; i++) {
        final p1 = stroke[i].point;
        final p2 = stroke[i + 1].point;
        final segDist = _distanceToSegment(point, p1, p2);

        if (segDist <= maxEraseDist) {
          erasedAny = true;
          if (currentSegment.length > 1) {
            newStrokes.add(currentSegment);
          }
          currentSegment = [stroke[i + 1]];
        } else {
          currentSegment.add(stroke[i + 1]);
        }
      }

      if (currentSegment.length > 1) {
        newStrokes.add(currentSegment);
      }
    }

    if (erasedAny) {
      _strokes
        ..clear()
        ..addAll(newStrokes);
    }
  }
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

      if (!mounted) return;
      setState(() {
        // Compare symbols while ignoring kudlit marks
        _isPracticeCorrect =
            _stripKudlits(recognized ?? '') == _stripKudlits(expected);
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
    _isPracticeCorrect = null;
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
      final path = _DrawPainter.buildSmoothPath(scaledStroke);
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final character = _characters[_currentIndex];
    final demoStrokes = baybayinPracticeStrokesForLabel(character["label"]!);

    _demoController
      ..reset()
      ..repeat();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: ShapeDecoration(
              color: isDarkMode ? AppColors.darkBox : AppColors.box,
              shape: const RoundedRectangleBorder(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.darkTextGrey
                          : AppColors.textGrey,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Demonstration",
                  style: AppTextStyles.body.copyWith(color: AppColors.grey12),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 284,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _demoController,
                    builder: (context, _) {
                      final strokeProgress = Curves.easeInOut.transform(
                        (_demoController.value / 0.82).clamp(0.0, 1.0),
                      );

                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: CustomPaint(
                          painter: BaybayinStrokeDemoPainter(
                            strokes: demoStrokes,
                            progress: strokeProgress,
                            inkColor: AppColors.grey12,
                          ),
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

  void _showSymbolPicker() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.72,
            ),
            decoration: ShapeDecoration(
              color: AppColors.grey1,
              shape: const RoundedRectangleBorder(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.darkTextGrey
                          : AppColors.textGrey,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Choose Symbol",
                  style: AppTextStyles.body.copyWith(color: AppColors.grey12),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                    itemCount: _characters.length,
                    itemBuilder: (context, index) {
                      final character = _characters[index];
                      final isSelected = index == _currentIndex;
                      final foregroundColor = isSelected
                          ? AppColors.blue9
                          : (isDarkMode ? AppColors.darkWhite : AppColors.dark);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectCharacterIndex(index);
                          });
                          Navigator.pop(sheetContext);
                        },
                        child: Container(
                          decoration: ShapeDecoration(
                            color: isSelected
                                ? AppColors.blue4
                                : AppColors.grey3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              character["symbol"]!,
                              style: AppTextStyles.heading.copyWith(
                                color: foregroundColor,
                                fontSize: 30,
                              ),
                            ),
                          ),
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
    );
  }

  bool _isSideDrawerExpanded = true;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final character = _characters[_currentIndex];

    return Scaffold(
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
              borderColor: AppColors.grey3,
              onTap: _showSymbolPicker,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildFloatingToolbar(isDarkMode),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: isDarkMode ? AppColors.darkBox : AppColors.box,
                        shape: RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(color: AppColors.grey6),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
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

                            ListenableBuilder(
                              listenable: _drawingController,
                              builder: (context, _) {
                                final hasDrawn = _drawingController.hasDrawn;
                                return Stack(
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
                                                          .withValues(
                                                            alpha: 0.14,
                                                          ),
                                                ),
                                          ),
                                        ),
                                      ),

                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: (details) {
                                        if (_isPracticeCorrect != null) {
                                          setState(() {
                                            _clearPracticeResult();
                                          });
                                        }
                                        _drawingController.startGesture(
                                          details.localPosition,
                                        );
                                      },
                                      onPanUpdate: (details) {
                                        _drawingController.updateGesture(
                                          details.localPosition,
                                        );
                                      },
                                      onPanEnd: (_) {
                                        _drawingController.endGesture();
                                      },
                                      onPanCancel: () {
                                        _drawingController.endGesture();
                                      },
                                      child: RepaintBoundary(
                                        child: CustomPaint(
                                          size: Size.infinite,
                                          painter: _DrawPainter(
                                            _drawingController.strokes,
                                            isDarkMode,
                                            eraserPosition: _drawingController
                                                .eraserPosition,
                                          ),
                                        ),
                                      ),
                                    ),

                                    if (!hasDrawn && !_showStrokeGuide)
                                      IgnorePointer(
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Draw Character Here",
                                                style: AppTextStyles.body
                                                    .copyWith(
                                                      color: AppColors.grey8,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_isPracticeCorrect != null)
                    Button(
                      label: "Try Again",
                      onTap: _tryAgain,
                      type: ButtonType.outline,
                      customBorderColor: AppColors.grey3,
                      width: double.infinity,
                    )
                  else
                    Button(
                      label: _isChecking ? "Checking" : "Check",
                      onTap: _isChecking ? null : _checkPractice,
                      type: ButtonType.primary,
                      customBackgroundColor: AppColors.blue9,
                      width: double.infinity,
                    ),
                ],
              ),
            ),

            _buildSideDrawerHandle(isDarkMode, character),
          ],
        ),
      ),
    );
  }

  Widget _buildStrokeIconButton(bool isDarkMode) {
    return ListenableBuilder(
      listenable: _drawingController,
      builder: (context, _) {
        final strokeWidth = _drawingController.strokeWidth;
        return CustomIconButton(
          size: 40,
          color: Colors.transparent,
          borderColor: AppColors.grey7,
          onTap: _changeStroke,
          child: Center(
            child: Container(
              width: strokeWidth * 2,
              height: strokeWidth * 2,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkWhite : AppColors.dark,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbarDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: AppColors.grey7,
    );
  }

  Widget _buildFloatingToolbar(bool isDarkMode) {
    return ListenableBuilder(
      listenable: _drawingController,
      builder: (context, _) {
        final isEraser = _drawingController.isEraserMode;
        return ClipRRect(
          borderRadius: BorderRadius.circular(64),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.grey3,
                borderRadius: BorderRadius.circular(64),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButton(
                    icon: Icons.undo,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: AppColors.grey7,
                    onTap: _drawingController.canUndo ? _undo : null,
                  ),
                  CustomIconButton(
                    icon: Icons.redo,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: AppColors.grey7,
                    onTap: _drawingController.canRedo ? _redo : null,
                  ),

                  _buildToolbarDivider(),

                  CustomIconButton(
                    icon: Icons.edit,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: !isEraser ? AppColors.blue9 : AppColors.grey7,
                    iconColor: !isEraser ? AppColors.blue9 : null,
                    onTap: _setPenMode,
                  ),
                  CustomIconButton(
                    icon: Icons.cleaning_services_outlined,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: isEraser ? AppColors.blue9 : AppColors.grey7,
                    iconColor: isEraser ? AppColors.blue9 : null,
                    onTap: _setEraserMode,
                  ),
                  _buildStrokeIconButton(isDarkMode),

                  _buildToolbarDivider(),

                  CustomIconButton(
                    icon: Icons.gesture,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: _showStrokeGuide
                        ? AppColors.blue9
                        : AppColors.grey7,
                    iconColor: _showStrokeGuide ? AppColors.blue9 : null,
                    onTap: _toggleStrokeGuide,
                  ),
                  CustomIconButton(
                    icon: Icons.play_circle_outline,
                    iconSize: 22,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: AppColors.grey7,
                    onTap: _showDemonstrationGif,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            color: AppColors.grey4,
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
                      color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          character["symbol"]!,
                          style: AppTextStyles.heading.copyWith(
                            color: isDarkMode
                                ? AppColors.darkWhite
                                : AppColors.dark,
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
                  color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
                ),
        ),
      ),
    );
  }
}

class _DrawPainter extends CustomPainter {
  final List<List<StrokePoint>> strokes;
  final bool isDarkMode;
  final Offset? eraserPosition;

  _DrawPainter(this.strokes, this.isDarkMode, {this.eraserPosition});

  static Path buildSmoothPath(List<StrokePoint> stroke) {
    final path = Path();
    if (stroke.isEmpty) return path;

    if (stroke.length == 1) {
      path.addOval(
        Rect.fromCircle(
          center: stroke.first.point,
          radius: stroke.first.strokeWidth / 2,
        ),
      );
      return path;
    }

    path.moveTo(stroke.first.point.dx, stroke.first.point.dy);

    if (stroke.length == 2) {
      path.lineTo(stroke.last.point.dx, stroke.last.point.dy);
      return path;
    }

    for (int i = 1; i < stroke.length - 1; i++) {
      final p0 = stroke[i].point;
      final p1 = stroke[i + 1].point;
      final midX = (p0.dx + p1.dx) / 2;
      final midY = (p0.dy + p1.dy) / 2;
      path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
    }
    path.lineTo(stroke.last.point.dx, stroke.last.point.dy);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    final paint = Paint()
      ..color = isDarkMode ? AppColors.darkWhite : AppColors.dark
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      if (stroke.length == 1) {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          stroke.first.point,
          stroke.first.strokeWidth / 2,
          paint,
        );
        paint.style = PaintingStyle.stroke;
        continue;
      }

      paint.strokeWidth = stroke.first.strokeWidth;
      final path = buildSmoothPath(stroke);
      canvas.drawPath(path, paint);
    }

    if (eraserPosition != null) {
      final eraserPaint = Paint()
        ..color = AppColors.grey12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(eraserPosition!, 24.0, eraserPaint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.grey4.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = AppColors.grey4
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double step = 32.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      accentPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DrawPainter oldDelegate) => true;
}
