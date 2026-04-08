import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SugarLevelChart extends StatelessWidget {
  final List<SugarLevelModel> levels;
  const SugarLevelChart({super.key, required this.levels});

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return Container(
        height: SizeConfig.height * 0.25,
        alignment: Alignment.center,
        child: const Text("No data yet"),
      );
    }

    return Container(
      height: SizeConfig.height * 0.25,
      padding: const EdgeInsets.only(right: 18, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < levels.length) {
                    final date = levels[value.toInt()].createdAt;
                    return Text("${date.day}/${date.month}", style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: levels.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.level)).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
