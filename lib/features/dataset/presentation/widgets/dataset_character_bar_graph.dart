import "dart:math";
import "package:baybai/core/theme/text.dart";
import "package:flutter/material.dart";
import "package:fl_chart/fl_chart.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";

class DatasetCharacterBarGraph extends StatelessWidget {
  final List<DatasetEntry> entries;
  final bool isDarkMode;

  const DatasetCharacterBarGraph({
    super.key,
    required this.entries,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyState("No entries");
    }

    final Map<String, _BaseCharStats> statsMap = {};
    for (final entry in entries) {
      final title = entry.titleBaybayin;
      final parsed = _parseBaybayinString(title);
      for (final char in parsed) {
        final stats = statsMap.putIfAbsent(
          char.base,
          () => _BaseCharStats(char.base),
        );
        if (char.modifier == null) {
          stats.noneCount++;
        } else if (char.modifier == '\u1712') {
          stats.topCount++;
        } else if (char.modifier == '\u1713') {
          stats.bottomCount++;
        } else if (char.modifier == '\u1714') {
          stats.killerCount++;
        }
      }
    }

    if (statsMap.isEmpty) {
      return _buildEmptyState("No character data");
    }

    // Sort by Abakada order: vowels first, then consonants (abakada), then comma/period
    final sortedStats = statsMap.values.toList()
      ..sort((a, b) {
        int indexA = _abakadaOrder.indexOf(a.base);
        int indexB = _abakadaOrder.indexOf(b.base);

        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;

        if (indexA != indexB) {
          return indexA.compareTo(indexB);
        }
        return a.base.compareTo(b.base);
      });

    final items = sortedStats;
    final counts = items.map((e) => e.total).toList();
    final maxValue = counts.reduce(max).toDouble();
    final yConfig = _calculateYAxisConfig(maxValue);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double chartWidth = items.length * 26.0 + 55.0;

        return Container(
          height: 284,
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkBox : AppColors.box,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    "Baybayin Characters",
                    style: AppTextStyles.bigbody.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegendItem("Base Character", AppColors.primary),
                    _buildLegendItem("Top Dot (i/e)", Colors.deepPurple),
                    _buildLegendItem("Bottom Dot (o/u)", Colors.cyan),
                    _buildLegendItem("Pamudpod (+)", Colors.green),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.start,
                          groupsSpace: 16,
                          minY: 0,
                          maxY: yConfig.maxY,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color:
                                    (isDarkMode ? Colors.white : Colors.black)
                                        .withOpacity(0.1),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              );
                            },
                          ),

                          barTouchData: BarTouchData(enabled: true),

                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                interval: yConfig.interval,
                                getTitlesWidget: (value, meta) {
                                  if (value % yConfig.interval != 0) {
                                    return const SizedBox();
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4,
                                    child: Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? AppColors.darkText
                                            : AppColors.text,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value % 1 != 0) {
                                    return const SizedBox();
                                  }
                                  final index = value.toInt();
                                  if (index < 0 || index >= items.length) {
                                    return const SizedBox();
                                  }

                                  final label = items[index].base;

                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 8,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontFamily: 'Baybayin',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? AppColors.darkText
                                            : AppColors.text,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          barGroups: List.generate(items.length, (index) {
                            final item = items[index];
                            final double totalValue = item.total.toDouble();

                            final List<_Segment> activeSegments = [];
                            if (item.noneCount > 0) {
                              activeSegments.add(
                                _Segment(item.noneCount, AppColors.primary),
                              );
                            }
                            if (item.topCount > 0) {
                              activeSegments.add(
                                _Segment(item.topCount, Colors.deepPurple),
                              );
                            }
                            if (item.bottomCount > 0) {
                              activeSegments.add(
                                _Segment(item.bottomCount, Colors.cyan),
                              );
                            }
                            if (item.killerCount > 0) {
                              activeSegments.add(
                                _Segment(item.killerCount, Colors.green),
                              );
                            }

                            final List<BarChartRodStackItem> stackItems = [];
                            double currentY = 0;
                            const double gapSize = 0.2;

                            for (int j = 0; j < activeSegments.length; j++) {
                              final seg = activeSegments[j];
                              final val = seg.value.toDouble();

                              if (j > 0) {
                                stackItems.add(
                                  BarChartRodStackItem(
                                    currentY,
                                    currentY + gapSize,
                                    isDarkMode
                                        ? AppColors.darkBox
                                        : AppColors.box,
                                  ),
                                );
                                currentY += gapSize;
                              }

                              stackItems.add(
                                BarChartRodStackItem(
                                  currentY,
                                  currentY + val - (j > 0 ? gapSize : 0),
                                  seg.color,
                                ),
                              );
                              currentY += val - (j > 0 ? gapSize : 0);
                            }

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: totalValue,
                                  width: 10,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                    bottom: Radius.circular(8),
                                  ),
                                  color: AppColors.primary,
                                  rodStackItems: stackItems,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: yConfig.maxY,
                                    color:
                                        (isDarkMode
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(0.08),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBox : AppColors.box,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
          ),
        ),
      ),
    );
  }
}

class _BaybayinChar {
  final String base;
  final String? modifier;

  _BaybayinChar(this.base, this.modifier);
}

class _BaseCharStats {
  final String base;
  int noneCount = 0;
  int topCount = 0;
  int bottomCount = 0;
  int killerCount = 0;

  _BaseCharStats(this.base);

  int get total => noneCount + topCount + bottomCount + killerCount;
}

List<_BaybayinChar> _parseBaybayinString(String text) {
  final List<_BaybayinChar> result = [];
  final runes = text.runes.toList();
  for (int i = 0; i < runes.length; i++) {
    final rune = runes[i];
    final charStr = String.fromCharCode(rune);

    if (charStr.trim().isEmpty) continue;

    if (rune == 0x1712 || rune == 0x1713 || rune == 0x1714) {
      continue;
    }

    String? modifier;
    if (i + 1 < runes.length) {
      final nextRune = runes[i + 1];
      if (nextRune == 0x1712 || nextRune == 0x1713 || nextRune == 0x1714) {
        modifier = String.fromCharCode(nextRune);
        i++;
      }
    }

    result.add(_BaybayinChar(charStr, modifier));
  }
  return result;
}

const List<String> _abakadaOrder = [
  // Vowels
  'ᜀ', // A (U+1700)
  'ᜁ', // I/E (U+1701)
  'ᜂ', // O/U (U+1702)
  // Consonants in Abakada order: B, K, D, G, H, L, M, N, NG, P, R, S, T, W, Y
  'ᜊ', // Ba (U+170A)
  'ᜃ', // Ka (U+1703)
  'ᜇ', // Da (U+1707)
  'ᜄ', // Ga (U+1704)
  'ᜑ', // Ha (U+1710)
  'ᜎ', // La (U+170D)
  'ᜋ', // Ma (U+170B)
  'ᜈ', // Na (U+1708)
  'ᜅ', // Nga (U+1705)
  'ᜉ', // Pa (U+1709)
  'ᜟ', // Ra (U+171F)
  'ᜐ', // Sa (U+170F)
  'ᜆ', // Ta (U+1706)
  'ᜏ', // Wa (U+170E)
  'ᜌ', // Ya (U+170C)
  // Punctuation (comma and period: both Baybayin dandas and standard western characters)
  '᜵', // Single danda (comma) (U+1735)
  ',', // Western comma
  '᜶', // Double danda (period) (U+1736)
  '.', // Western period
];

class _Segment {
  final int value;
  final Color color;

  _Segment(this.value, this.color);
}

class _YAxisConfig {
  final double maxY;
  final double interval;

  _YAxisConfig(this.maxY, this.interval);
}

_YAxisConfig _calculateYAxisConfig(double maxValue) {
  if (maxValue <= 0) {
    return _YAxisConfig(5, 1);
  }
  if (maxValue <= 5) {
    return _YAxisConfig(5, 1);
  }

  // We want to divide the range into roughly 4 intervals
  final double rawStep = (maxValue * 1.1) / 4;

  // Find the magnitude (power of 10) of the raw step
  final double log10 = log(rawStep) / ln10;
  final double magnitude = pow(10, log10.floor()).toDouble();

  final double normalizedStep = rawStep / magnitude;

  double step;
  if (normalizedStep <= 1) {
    step = 1;
  } else if (normalizedStep <= 2) {
    step = 2;
  } else if (normalizedStep <= 5) {
    step = 5;
  } else {
    step = 10;
  }
  step *= magnitude;

  // Round the max Y to the next step
  final double maxY = (maxValue * 1.1 / step).ceil() * step;

  return _YAxisConfig(maxY, step);
}
