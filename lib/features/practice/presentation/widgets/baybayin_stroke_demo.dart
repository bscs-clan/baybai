import "dart:math" as math;

import "package:flutter/material.dart";

class BaybayinStrokeDemoPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final double progress;
  final Color inkColor;

  const BaybayinStrokeDemoPainter({
    required this.strokes,
    required this.progress,
    required this.inkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    final totalPoints = strokes.fold<int>(
      0,
      (total, stroke) => total + stroke.length,
    );
    final visiblePoints = (totalPoints * progress).round();

    final ink = Paint()
      ..color = inkColor
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    var remaining = visiblePoints;
    for (final stroke in strokes) {
      if (remaining <= 0) break;

      final visibleInStroke = math.min(remaining, stroke.length);
      remaining -= visibleInStroke;
      if (visibleInStroke < 2) continue;

      final scaled = stroke
          .sublist(0, visibleInStroke)
          .map((point) => Offset(point.dx * size.width, point.dy * size.height))
          .toList();
      final path = _smoothPath(scaled);

      canvas.drawPath(path, ink);

      if (remaining == 0 && progress < 0.99) {
        final tip = scaled.last;
        canvas.drawCircle(tip, 5.5, Paint()..color = inkColor);
      }
    }
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i++) {
      final mid = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        (points[i].dy + points[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant BaybayinStrokeDemoPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.progress != progress ||
        oldDelegate.inkColor != inkColor;
  }
}

List<List<Offset>> baybayinPracticeStrokesForLabel(String label) {
  return switch (label) {
    "A" => _buildA(),
    "E/I" => _buildI(),
    "O/U" => _buildU(),
    "Ka" => _buildKa(),
    "Ga" => _buildGa(),
    "Nga" => _buildNga(),
    "Ta" => _buildTa(),
    "Da/Ra" => _buildDa(),
    "Na" => _buildNa(),
    "Pa" => _buildPa(),
    "Ba" => _buildBa(),
    "Ma" => _buildMa(),
    "Ya" => _buildYa(),
    "La" => _buildLa(),
    "Wa" => _buildWa(),
    "Sa" => _buildSa(),
    "Ha" => _buildHa(),
    _ => const [],
  };
}

List<Offset> _line(Offset a, Offset b, {int n = 24}) => List.generate(
  n + 1,
  (i) => Offset(
    a.dx + i / n * (b.dx - a.dx),
    a.dy + i / n * (b.dy - a.dy),
  ),
);

List<Offset> _quadratic(Offset p0, Offset p1, Offset p2, {int n = 36}) {
  return List.generate(n + 1, (i) {
    final t = i / n;
    final mt = 1 - t;
    return Offset(
      mt * mt * p0.dx + 2 * mt * t * p1.dx + t * t * p2.dx,
      mt * mt * p0.dy + 2 * mt * t * p1.dy + t * t * p2.dy,
    );
  });
}

List<Offset> _cubic(
  Offset p0,
  Offset c1,
  Offset c2,
  Offset p3, {
  int n = 48,
}) {
  return List.generate(n + 1, (i) {
    final t = i / n;
    final mt = 1 - t;
    return Offset(
      mt * mt * mt * p0.dx +
          3 * mt * mt * t * c1.dx +
          3 * mt * t * t * c2.dx +
          t * t * t * p3.dx,
      mt * mt * mt * p0.dy +
          3 * mt * mt * t * c1.dy +
          3 * mt * t * t * c2.dy +
          t * t * t * p3.dy,
    );
  });
}

List<List<Offset>> _buildA() {
  final s1a = _cubic(
    const Offset(0.034, 0.197),
    const Offset(0.068, 0.027),
    const Offset(0.317, 0.000),
    const Offset(0.317, 0.253),
  );
  final s1b = _cubic(
    const Offset(0.317, 0.253),
    const Offset(0.317, 0.506),
    const Offset(0.295, 0.956),
    const Offset(0.469, 0.956),
  );
  final s1c = _cubic(
    const Offset(0.469, 0.956),
    const Offset(0.691, 0.956),
    const Offset(0.747, 0.452),
    const Offset(0.792, 0.325),
  );
  final s1d = _cubic(
    const Offset(0.792, 0.325),
    const Offset(0.837, 0.198),
    const Offset(0.922, 0.197),
    const Offset(0.967, 0.325),
  );
  final topBar = _line(const Offset(0.134, 0.337), const Offset(0.456, 0.337));
  final bottomBar = _line(
    const Offset(0.166, 0.500),
    const Offset(0.317, 0.500),
  );

  return [
    [...s1a, ...s1b, ...s1c, ...s1d],
    topBar,
    bottomBar,
  ];
}

List<List<Offset>> _buildI() {
  final s1a = _quadratic(
    const Offset(0.146, 0.172),
    const Offset(0.245, 0.453),
    const Offset(0.345, 0.395),
  );
  final s1b = _quadratic(
    const Offset(0.345, 0.395),
    const Offset(0.470, 0.320),
    const Offset(0.589, 0.193),
  );
  final s1c = _quadratic(
    const Offset(0.589, 0.193),
    const Offset(0.665, 0.120),
    const Offset(0.742, 0.199),
  );
  final s1d = _quadratic(
    const Offset(0.742, 0.199),
    const Offset(0.774, 0.240),
    const Offset(0.805, 0.354),
  );
  final s2a = _quadratic(
    const Offset(0.120, 0.865),
    const Offset(0.363, 0.738),
    const Offset(0.394, 0.505),
  );
  final s2b = _quadratic(
    const Offset(0.394, 0.505),
    const Offset(0.547, 0.775),
    const Offset(0.632, 0.488),
  );
  final s2c = _quadratic(
    const Offset(0.632, 0.488),
    const Offset(0.749, 0.880),
    const Offset(0.880, 0.605),
  );

  return [
    [...s1a, ...s1b, ...s1c, ...s1d],
    [...s2a, ...s2b, ...s2c],
  ];
}

List<List<Offset>> _buildU() {
  final s1a = _quadratic(
    const Offset(0.270, 0.120),
    const Offset(0.545, 0.020),
    const Offset(0.685, 0.235),
  );
  final s1b = _quadratic(
    const Offset(0.685, 0.235),
    const Offset(0.715, 0.340),
    const Offset(0.565, 0.410),
  );
  final s1c = _quadratic(
    const Offset(0.565, 0.410),
    const Offset(0.390, 0.415),
    const Offset(0.370, 0.410),
  );
  final s1d = _cubic(
    const Offset(0.375, 0.411),
    const Offset(0.525, 0.411),
    const Offset(0.775, 0.461),
    const Offset(0.775, 0.611),
  );
  final s1e = _quadratic(
    const Offset(0.775, 0.611),
    const Offset(0.625, 0.911),
    const Offset(0.275, 0.811),
  );

  return [s1a, s1b, s1c, s1d, s1e];
}

List<List<Offset>> _buildBa() {
  final s1 = _cubic(
    const Offset(0.179, 0.601),
    const Offset(0.303, 0.784),
    const Offset(0.502, 0.563),
    const Offset(0.502, 0.563),
  );
  final s2 = _cubic(
    const Offset(0.502, 0.563),
    const Offset(0.711, 0.800),
    const Offset(0.824, 0.586),
    const Offset(0.824, 0.586),
  );
  final s3 = _cubic(
    const Offset(0.824, 0.586),
    const Offset(0.937, 0.373),
    const Offset(0.636, 0.200),
    const Offset(0.502, 0.211),
  );
  final s4 = _cubic(
    const Offset(0.502, 0.211),
    const Offset(0.367, 0.220),
    const Offset(0.054, 0.419),
    const Offset(0.179, 0.601),
  );

  return [
    [...s1, ...s2, ...s3, ...s4],
  ];
}

List<List<Offset>> _buildKa() {
  final t1 = _cubic(
    const Offset(0.157, 0.174),
    const Offset(0.157, 0.174),
    const Offset(0.249, 0.282),
    const Offset(0.349, 0.290),
  );
  final t2 = _cubic(
    const Offset(0.349, 0.290),
    const Offset(0.458, 0.299),
    const Offset(0.547, 0.157),
    const Offset(0.656, 0.160),
  );
  final t3 = _cubic(
    const Offset(0.656, 0.160),
    const Offset(0.762, 0.163),
    const Offset(0.848, 0.290),
    const Offset(0.848, 0.290),
  );
  final b1 = _cubic(
    const Offset(0.151, 0.751),
    const Offset(0.151, 0.751),
    const Offset(0.251, 0.845),
    const Offset(0.351, 0.839),
  );
  final b2 = _cubic(
    const Offset(0.351, 0.839),
    const Offset(0.460, 0.832),
    const Offset(0.537, 0.678),
    const Offset(0.646, 0.665),
  );
  final b3 = _cubic(
    const Offset(0.646, 0.665),
    const Offset(0.751, 0.653),
    const Offset(0.847, 0.767),
    const Offset(0.847, 0.767),
  );
  final stem = _line(
    const Offset(0.468, 0.289),
    const Offset(0.485, 0.747),
    n: 20,
  );

  return [
    [...t1, ...t2, ...t3],
    [...b1, ...b2, ...b3],
    stem,
  ];
}

List<List<Offset>> _buildGa() {
  final s1 = _cubic(
    const Offset(0.190, 0.266),
    const Offset(0.494, 0.120),
    const Offset(0.767, 0.501),
    const Offset(0.190, 0.484),
  );
  final s2 = _cubic(
    const Offset(0.190, 0.484),
    const Offset(0.767, 0.501),
    const Offset(0.639, 0.716),
    const Offset(0.156, 0.684),
  );
  final r1 = _cubic(
    const Offset(0.481, 0.279),
    const Offset(0.520, 0.232),
    const Offset(0.610, 0.227),
    const Offset(0.662, 0.250),
  );
  final r2 = _cubic(
    const Offset(0.662, 0.250),
    const Offset(0.760, 0.300),
    const Offset(0.750, 0.491),
    const Offset(0.693, 0.601),
  );
  final r3 = _cubic(
    const Offset(0.693, 0.601),
    const Offset(0.680, 0.640),
    const Offset(0.710, 0.690),
    const Offset(0.844, 0.720),
  );

  return [
    [...s1, ...s2],
    [...r1, ...r2, ...r3],
  ];
}

List<List<Offset>> _buildNga() {
  final a1 = _cubic(
    const Offset(0.261, 0.148),
    const Offset(0.261, 0.148),
    const Offset(0.128, 0.208),
    const Offset(0.147, 0.309),
  );
  final a2 = _cubic(
    const Offset(0.147, 0.309),
    const Offset(0.165, 0.409),
    const Offset(0.261, 0.387),
    const Offset(0.261, 0.387),
  );
  final a3 = _cubic(
    const Offset(0.261, 0.387),
    const Offset(0.400, 0.360),
    const Offset(0.460, 0.355),
    const Offset(0.460, 0.355),
  );
  final a4 = _cubic(
    const Offset(0.460, 0.355),
    const Offset(0.520, 0.351),
    const Offset(0.578, 0.387),
    const Offset(0.578, 0.480),
  );
  final a5 = _cubic(
    const Offset(0.578, 0.480),
    const Offset(0.578, 0.573),
    const Offset(0.514, 0.638),
    const Offset(0.460, 0.638),
  );
  final a6 = _cubic(
    const Offset(0.460, 0.638),
    const Offset(0.406, 0.638),
    const Offset(0.316, 0.592),
    const Offset(0.261, 0.602),
  );
  final a7 = _cubic(
    const Offset(0.261, 0.602),
    const Offset(0.206, 0.613),
    const Offset(0.158, 0.640),
    const Offset(0.147, 0.703),
  );
  final a8 = _cubic(
    const Offset(0.147, 0.703),
    const Offset(0.133, 0.778),
    const Offset(0.216, 0.794),
    const Offset(0.261, 0.852),
  );
  final b1 = _cubic(
    const Offset(0.578, 0.480),
    const Offset(0.578, 0.480),
    const Offset(0.649, 0.409),
    const Offset(0.674, 0.387),
  );
  final b2 = _cubic(
    const Offset(0.674, 0.387),
    const Offset(0.700, 0.366),
    const Offset(0.748, 0.328),
    const Offset(0.796, 0.355),
  );
  final b3 = _cubic(
    const Offset(0.796, 0.355),
    const Offset(0.848, 0.385),
    const Offset(0.866, 0.451),
    const Offset(0.847, 0.513),
  );
  final b4 = _cubic(
    const Offset(0.847, 0.513),
    const Offset(0.832, 0.562),
    const Offset(0.793, 0.567),
    const Offset(0.758, 0.602),
  );

  return [
    [...a1, ...a2, ...a3, ...a4, ...a5, ...a6, ...a7, ...a8],
    [...b1, ...b2, ...b3, ...b4],
  ];
}

List<List<Offset>> _buildDa() {
  final t1 = _cubic(
    const Offset(0.156, 0.217),
    const Offset(0.156, 0.217),
    const Offset(0.104, 0.387),
    const Offset(0.248, 0.387),
  );
  final t2 = _cubic(
    const Offset(0.248, 0.387),
    const Offset(0.492, 0.336),
    const Offset(0.639, 0.184),
    const Offset(0.685, 0.174),
  );
  final t3 = _cubic(
    const Offset(0.685, 0.174),
    const Offset(0.768, 0.151),
    const Offset(0.894, 0.205),
    const Offset(0.839, 0.426),
  );
  final b1 = _cubic(
    const Offset(0.248, 0.387),
    const Offset(0.178, 0.520),
    const Offset(0.101, 0.833),
    const Offset(0.317, 0.829),
  );
  final b2 = _cubic(
    const Offset(0.317, 0.829),
    const Offset(0.534, 0.826),
    const Offset(0.668, 0.687),
    const Offset(0.693, 0.664),
  );
  final b3 = _cubic(
    const Offset(0.693, 0.664),
    const Offset(0.776, 0.588),
    const Offset(0.854, 0.637),
    const Offset(0.808, 0.728),
  );

  return [
    [...t1, ...t2, ...t3],
    [...b1, ...b2, ...b3],
  ];
}

List<List<Offset>> _buildLa() {
  final a1 = _cubic(
    const Offset(0.243, 0.272),
    const Offset(0.243, 0.272),
    const Offset(0.311, 0.336),
    const Offset(0.385, 0.341),
  );
  final a2 = _cubic(
    const Offset(0.385, 0.341),
    const Offset(0.428, 0.344),
    const Offset(0.466, 0.322),
    const Offset(0.504, 0.302),
  );
  final a3 = _cubic(
    const Offset(0.504, 0.302),
    const Offset(0.540, 0.282),
    const Offset(0.575, 0.263),
    const Offset(0.615, 0.264),
  );
  final a4 = _cubic(
    const Offset(0.615, 0.264),
    const Offset(0.693, 0.266),
    const Offset(0.757, 0.341),
    const Offset(0.757, 0.341),
  );
  final b1 = _cubic(
    const Offset(0.518, 0.297),
    const Offset(0.518, 0.297),
    const Offset(0.425, 0.391),
    const Offset(0.442, 0.442),
  );
  final b2 = _cubic(
    const Offset(0.442, 0.442),
    const Offset(0.459, 0.495),
    const Offset(0.556, 0.472),
    const Offset(0.562, 0.497),
  );
  final b3 = _cubic(
    const Offset(0.562, 0.497),
    const Offset(0.575, 0.556),
    const Offset(0.394, 0.569),
    const Offset(0.442, 0.600),
  );
  final b4 = _cubic(
    const Offset(0.442, 0.600),
    const Offset(0.489, 0.632),
    const Offset(0.542, 0.621),
    const Offset(0.562, 0.668),
  );
  final b5 = _cubic(
    const Offset(0.562, 0.668),
    const Offset(0.582, 0.716),
    const Offset(0.442, 0.747),
    const Offset(0.442, 0.747),
  );

  return [
    [...a1, ...a2, ...a3, ...a4],
    [...b1, ...b2, ...b3, ...b4, ...b5],
  ];
}

List<List<Offset>> _buildMa() {
  final s1 = _cubic(
    const Offset(0.148, 0.356),
    const Offset(0.266, 0.337),
    const Offset(0.282, 0.341),
    const Offset(0.257, 0.419),
  );
  final s2 = _cubic(
    const Offset(0.257, 0.419),
    const Offset(0.220, 0.496),
    const Offset(0.228, 0.800),
    const Offset(0.383, 0.709),
  );
  final s3 = _cubic(
    const Offset(0.383, 0.709),
    const Offset(0.538, 0.617),
    const Offset(0.564, 0.449),
    const Offset(0.579, 0.419),
  );
  final s4 = _cubic(
    const Offset(0.579, 0.419),
    const Offset(0.579, 0.419),
    const Offset(0.614, 0.319),
    const Offset(0.684, 0.260),
  );
  final s5 = _cubic(
    const Offset(0.684, 0.260),
    const Offset(0.754, 0.200),
    const Offset(0.848, 0.202),
    const Offset(0.852, 0.252),
  );
  final crossBar = _cubic(
    const Offset(0.579, 0.419),
    const Offset(0.435, 0.358),
    const Offset(0.319, 0.377),
    const Offset(0.257, 0.419),
  );

  return [
    [...s1, ...s2, ...s3, ...s4, ...s5],
    crossBar,
  ];
}

List<List<Offset>> _buildNa() {
  final a1 = _cubic(
    const Offset(0.169, 0.758),
    const Offset(0.169, 0.758),
    const Offset(0.045, 0.224),
    const Offset(0.483, 0.212),
  );
  final a2 = _cubic(
    const Offset(0.483, 0.212),
    const Offset(0.934, 0.200),
    const Offset(0.839, 0.758),
    const Offset(0.839, 0.758),
  );
  final b1 = _cubic(
    const Offset(0.483, 0.212),
    const Offset(0.483, 0.212),
    const Offset(0.614, 0.280),
    const Offset(0.599, 0.342),
  );
  final b2 = _cubic(
    const Offset(0.599, 0.342),
    const Offset(0.588, 0.390),
    const Offset(0.481, 0.388),
    const Offset(0.483, 0.436),
  );
  final b3 = _cubic(
    const Offset(0.483, 0.436),
    const Offset(0.485, 0.484),
    const Offset(0.596, 0.479),
    const Offset(0.599, 0.525),
  );
  final b4 = _cubic(
    const Offset(0.599, 0.525),
    const Offset(0.603, 0.575),
    const Offset(0.483, 0.568),
    const Offset(0.483, 0.618),
  );
  final b5 = _cubic(
    const Offset(0.483, 0.618),
    const Offset(0.482, 0.668),
    const Offset(0.608, 0.674),
    const Offset(0.599, 0.724),
  );
  final b6 = _cubic(
    const Offset(0.599, 0.724),
    const Offset(0.591, 0.770),
    const Offset(0.483, 0.800),
    const Offset(0.483, 0.800),
  );

  return [
    [...a1, ...a2],
    [...b1, ...b2, ...b3, ...b4, ...b5, ...b6],
  ];
}

List<List<Offset>> _buildPa() {
  final s1 = _cubic(
    const Offset(0.150, 0.504),
    const Offset(0.150, 0.504),
    const Offset(0.212, 0.452),
    const Offset(0.261, 0.446),
  );
  final s2 = _cubic(
    const Offset(0.261, 0.446),
    const Offset(0.385, 0.433),
    const Offset(0.187, 0.701),
    const Offset(0.301, 0.750),
  );
  final s3 = _cubic(
    const Offset(0.301, 0.750),
    const Offset(0.418, 0.800),
    const Offset(0.529, 0.586),
    const Offset(0.566, 0.446),
  );
  final s4 = _cubic(
    const Offset(0.566, 0.446),
    const Offset(0.587, 0.367),
    const Offset(0.628, 0.202),
    const Offset(0.701, 0.201),
  );
  final s5 = _cubic(
    const Offset(0.701, 0.201),
    const Offset(0.785, 0.200),
    const Offset(0.850, 0.275),
    const Offset(0.850, 0.275),
  );
  final bar = _line(
    const Offset(0.576, 0.414),
    const Offset(0.760, 0.479),
    n: 20,
  );

  return [
    [...s1, ...s2, ...s3, ...s4, ...s5],
    bar,
  ];
}

List<List<Offset>> _buildSa() {
  final bar = _line(
    const Offset(0.163, 0.200),
    const Offset(0.266, 0.200),
    n: 16,
  );
  final s1 = _cubic(
    const Offset(0.266, 0.200),
    const Offset(0.266, 0.200),
    const Offset(0.213, 0.773),
    const Offset(0.266, 0.773),
  );
  final s2 = _cubic(
    const Offset(0.266, 0.773),
    const Offset(0.294, 0.773),
    const Offset(0.414, 0.200),
    const Offset(0.453, 0.200),
  );
  final s3 = _cubic(
    const Offset(0.453, 0.200),
    const Offset(0.640, 0.200),
    const Offset(0.638, 0.218),
    const Offset(0.640, 0.334),
  );
  final s4 = _cubic(
    const Offset(0.640, 0.334),
    const Offset(0.642, 0.437),
    const Offset(0.492, 0.500),
    const Offset(0.492, 0.500),
  );
  final s5 = _cubic(
    const Offset(0.492, 0.500),
    const Offset(0.492, 0.500),
    const Offset(0.593, 0.587),
    const Offset(0.591, 0.675),
  );
  final s6 = _cubic(
    const Offset(0.591, 0.675),
    const Offset(0.587, 0.800),
    const Offset(0.375, 0.773),
    const Offset(0.375, 0.773),
  );

  return [
    bar,
    [...s1, ...s2, ...s3, ...s4, ...s5, ...s6],
  ];
}

List<List<Offset>> _buildTa() {
  final s1 = _cubic(
    const Offset(0.854, 0.300),
    const Offset(0.728, 0.200),
    const Offset(0.480, 0.282),
    const Offset(0.324, 0.583),
  );
  final s2 = _cubic(
    const Offset(0.324, 0.583),
    const Offset(0.292, 0.646),
    const Offset(0.264, 0.718),
    const Offset(0.241, 0.800),
  );
  final crossBar = _cubic(
    const Offset(0.324, 0.583),
    const Offset(0.184, 0.619),
    const Offset(0.124, 0.609),
    const Offset(0.153, 0.509),
  );

  return [
    [...s1, ...s2],
    crossBar,
  ];
}

List<List<Offset>> _buildWa() {
  final s1 = _cubic(
    const Offset(0.157, 0.448),
    const Offset(0.112, 0.455),
    const Offset(0.391, 0.413),
    const Offset(0.374, 0.482),
  );
  final s2 = _cubic(
    const Offset(0.374, 0.482),
    const Offset(0.357, 0.552),
    const Offset(0.225, 0.670),
    const Offset(0.307, 0.735),
  );
  final s3 = _cubic(
    const Offset(0.307, 0.735),
    const Offset(0.389, 0.800),
    const Offset(0.523, 0.788),
    const Offset(0.697, 0.680),
  );
  final s4 = _cubic(
    const Offset(0.697, 0.680),
    const Offset(0.872, 0.572),
    const Offset(0.991, 0.200),
    const Offset(0.470, 0.324),
  );

  return [
    [...s1, ...s2, ...s3, ...s4],
  ];
}

List<List<Offset>> _buildYa() {
  final s1 = _cubic(
    const Offset(0.148, 0.370),
    const Offset(0.148, 0.370),
    const Offset(0.210, 0.356),
    const Offset(0.244, 0.370),
  );
  final s2 = _cubic(
    const Offset(0.244, 0.370),
    const Offset(0.321, 0.402),
    const Offset(0.217, 0.499),
    const Offset(0.244, 0.575),
  );
  final s3 = _cubic(
    const Offset(0.244, 0.575),
    const Offset(0.323, 0.800),
    const Offset(0.643, 0.200),
    const Offset(0.748, 0.200),
  );
  final s4 = _cubic(
    const Offset(0.748, 0.200),
    const Offset(0.803, 0.200),
    const Offset(0.854, 0.239),
    const Offset(0.850, 0.291),
  );
  final s5 = _cubic(
    const Offset(0.850, 0.291),
    const Offset(0.847, 0.339),
    const Offset(0.694, 0.370),
    const Offset(0.694, 0.370),
  );

  return [
    [...s1, ...s2, ...s3, ...s4, ...s5],
  ];
}

List<List<Offset>> _buildHa() {
  final s1 = _cubic(
    const Offset(0.158, 0.380),
    const Offset(0.158, 0.380),
    const Offset(0.281, 0.580),
    const Offset(0.365, 0.580),
  );
  final s2 = _cubic(
    const Offset(0.365, 0.580),
    const Offset(0.475, 0.580),
    const Offset(0.525, 0.451),
    const Offset(0.635, 0.451),
  );
  final s3 = _cubic(
    const Offset(0.635, 0.451),
    const Offset(0.736, 0.451),
    const Offset(0.841, 0.580),
    const Offset(0.841, 0.580),
  );

  return [
    [...s1, ...s2, ...s3],
  ];
}
