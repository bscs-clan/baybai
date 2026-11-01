import "dart:math" as math;
import "package:flutter/material.dart";

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
