import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';

/// Line chart showing soil health score over years.
class SoilHealthChart extends StatelessWidget {
  const SoilHealthChart({
    super.key,
    required this.dataPoints,
    this.chartHeight = 200,
  });

  /// List of {year, score} maps. Score is 0-100.
  final List<Map<String, dynamic>> dataPoints;
  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    final years = <String>[];

    for (var i = 0; i < dataPoints.length; i++) {
      final year = dataPoints[i]['year'] as String? ?? '';
      final score = (dataPoints[i]['score'] as num?)?.toDouble() ?? 0.0;
      years.add(year);
      spots.add(FlSpot(i.toDouble(), score));
    }

    return Container(
      height: chartHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.agriGreen.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.agriGreen.withOpacity(0.2)),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (dataPoints.length - 1).toDouble(),
          minY: 40,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.agriGreen.withOpacity(0.15),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
                interval: 20,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < years.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        years[idx],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                interval: 1,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.agriGreen,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.agriGreen,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.agriGreen.withOpacity(0.3),
                    AppColors.agriGreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      ),
    );
  }
}
