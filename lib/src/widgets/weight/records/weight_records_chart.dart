import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/enums.dart';
import '../../../services/dtos/weight_record_dto.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import 'editor/weight_record_point_details_modal.dart';

class WeightRecordsChart extends StatelessWidget {
  static const double _fallbackXAxisPaddingMs = 43200000; // 12 hours
  static const double _fallbackXAxisIntervalMs = 86400000; // 1 day
  static const double _fallbackYAxisInterval = 1.0;
  static const double _fallbackYBuffer = 1.0;

  final Units units;
  final List<WeightRecordDto> records;
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const WeightRecordsChart({
    super.key,
    required this.units,
    required this.records,
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Text(
          "No data available",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    final chartRecords =
        records.where((r) => r.recordDate.isAfter(oneYearAgo)).toList();

    if (chartRecords.isEmpty) {
      return Center(
        child: Text(
          "No weight logs",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final isMetric = units == Units.metric;
    final spots = chartRecords.map((r) {
      final double x = r.recordDate.millisecondsSinceEpoch.toDouble();
      final double y = isMetric
          ? Converters.gramsToKg(r.weight)
          : Converters.gramsToLbs(r.weight);
      return FlSpot(x, y);
    }).toList();

    final minX = spots.first.x;
    final maxX = spots.last.x;
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    final yRange = maxY - minY;
    final yBuffer = yRange * 0.1;
    final adjustedMinY = minY - (yBuffer == 0 ? _fallbackYBuffer : yBuffer);
    final adjustedMaxY = maxY + (yBuffer == 0 ? _fallbackYBuffer : yBuffer);

    final hasSingleXValue = minX == maxX;
    final chartMinX = hasSingleXValue ? minX - _fallbackXAxisPaddingMs : minX;
    final chartMaxX = hasSingleXValue ? maxX + _fallbackXAxisPaddingMs : maxX;

    final xRange = chartMaxX - chartMinX;
    final xInterval = _safePositiveInterval(
      xRange / 4,
      fallback: _fallbackXAxisIntervalMs,
    );
    final yInterval = _safePositiveInterval(
      yRange / 4,
      fallback: _fallbackYAxisInterval,
    );
    final isLightTheme = theme.colorScheme.brightness == Brightness.light;
    final horizontalGuideColor = theme.colorScheme.onSurface.withValues(
      alpha: isLightTheme ? 0.28 : 0.36,
    );
    final axisBorderColor = theme.colorScheme.onSurface.withValues(
      alpha: isLightTheme ? 0.45 : 0.60,
    );

    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1.7,
        child: LineChart(
          LineChartData(
            minX: chartMinX,
            maxX: chartMaxX,
            minY: adjustedMinY,
            maxY: adjustedMaxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: horizontalGuideColor,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: sizes.fontSize * 1.2,
                    ),
                    Text(
                      ' Date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: sizes.fontSize,
                          ),
                    ),
                  ],
                ),
                axisNameSize: 28,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: xInterval,
                  getTitlesWidget: (value, meta) {
                    if (value == chartMaxX || value == chartMinX) {
                      return const SizedBox.shrink();
                    }
                    final date =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    final formatted = DateFormat.MMMd().format(date);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        formatted,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: sizes.smallFontSize,
                            ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monitor_weight,
                      size: sizes.fontSize * 1.2,
                    ),
                    Text(
                      ' Weight (${isMetric ? 'kg' : 'lbs'})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: sizes.fontSize,
                      ),
                    ),
                  ],
                ),
                axisNameSize: 28,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    // If it's the very top or bottom value, we might want to hide it to avoid clipping
                    if (value == adjustedMinY || value == adjustedMaxY) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      value.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: sizes.smallFontSize,
                          ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(
                  color: axisBorderColor,
                  width: 1,
                ),
                bottom: BorderSide(
                  color: axisBorderColor,
                  width: 1,
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 2,
                      strokeColor: Theme.of(context).colorScheme.surface,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: false,
              touchCallback: (event, touchResponse) {
                if (event is! FlTapUpEvent) {
                  return;
                }
                final touchedSpots = touchResponse?.lineBarSpots;
                if (touchedSpots == null || touchedSpots.isEmpty) {
                  return;
                }

                final spotIndex = touchedSpots.first.spotIndex;
                if (spotIndex < 0 || spotIndex >= chartRecords.length) {
                  return;
                }

                final record = chartRecords[spotIndex];
                WeightRecordPointDetailsModal.show(
                  context: context,
                  theme: theme,
                  sizes: sizes,
                  units: units,
                  record: record,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _safePositiveInterval(double value, {required double fallback}) {
    if (!value.isFinite || value <= 0) {
      return fallback;
    }
    return value;
  }
}
