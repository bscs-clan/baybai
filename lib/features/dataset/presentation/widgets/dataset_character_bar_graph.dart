import "dart:math";
import "package:baybai/core/theme/text.dart";
import "package:flutter/material.dart";
import "package:fl_chart/fl_chart.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "package:baybai/core/constants/abakada.dart";
import "package:number_display/number_display.dart";

// Bar graph colors
const Color baseColor = AppColors.primary;
const Color topColor = Colors.orange;
const Color bottomColor = Colors.red;
const Color viramaColor = Colors.green;

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

    // Initialize ALL characters with zero counts
    final Map<String, _BaseCharStats> statsMap = {};
    for (final base in abakadaOrder) {
      statsMap[base] = _BaseCharStats(base);
    }

    // Count actual data
    for (final entry in entries) {
      final title = entry.titleBaybayin;
      final parsed = _parseBaybayinString(title);
      for (final char in parsed) {
        final stats = statsMap[char.base];
        if (stats != null) {
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
    }

    final items = statsMap.values.toList();

    // Calculate overall total sum of all characters
    final int totalCharacters = items.fold(0, (sum, item) => sum + item.total);

    final counts = items.map((e) => e.total).toList();
    final maxValue = counts.isEmpty ? 0.0 : counts.reduce(max).toDouble();
    final yConfig = _calculateYAxisConfig(maxValue);
    final display = createDisplay(length: 8);

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
            padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "${display(totalCharacters)} total samples",
                    style: AppTextStyles.body.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextGrey
                          : AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegendItem("Base", baseColor),
                    _buildLegendItem("Top Dot (e/i)", topColor),
                    _buildLegendItem("Bottom Dot (o/u)", bottomColor),
                    _buildLegendItem("Virama (+)", viramaColor),
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
                          barTouchData: BarTouchData(enabled: false),
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
                                    space: 8,
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
                                  final isSpace = label == " ";

                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 8,
                                    child: Text(
                                      isSpace ? "␣" : label,
                                      style: TextStyle(
                                        fontFamily: isSpace ? null : 'Baybayin',
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
                                _Segment(item.noneCount, baseColor),
                              );
                            }
                            if (item.topCount > 0) {
                              activeSegments.add(
                                _Segment(item.topCount, topColor),
                              );
                            }
                            if (item.bottomCount > 0) {
                              activeSegments.add(
                                _Segment(item.bottomCount, bottomColor),
                              );
                            }
                            if (item.killerCount > 0) {
                              activeSegments.add(
                                _Segment(item.killerCount, viramaColor),
                              );
                            }

                            final List<BarChartRodStackItem> stackItems = [];
                            double currentY = 0;
                            const double gapSize = 0.5;

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
                                            .withOpacity(0.05),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(3),
          ),
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

// ==================== Helper Classes ====================

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

    if (charStr.trim().isEmpty && charStr != " ") continue;

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
  if (maxValue <= 0) return _YAxisConfig(5, 1);
  if (maxValue <= 5) return _YAxisConfig(5, 1);

  double niceMax = _getNiceNumber(maxValue);
  double interval = _getNiceInterval(niceMax);

  return _YAxisConfig(niceMax, interval);
}

double _getNiceNumber(double value) {
  if (value <= 10) return (value / 5).ceil() * 5;
  if (value <= 50) return (value / 10).ceil() * 10;
  if (value <= 100) return (value / 25).ceil() * 25;
  return (value / 50).ceil() * 50;
}

double _getNiceInterval(double maxY) {
  if (maxY <= 10) return 2;
  if (maxY <= 25) return 5;
  if (maxY <= 50) return 10;
  if (maxY <= 100) return 25;
  return 50;
}
