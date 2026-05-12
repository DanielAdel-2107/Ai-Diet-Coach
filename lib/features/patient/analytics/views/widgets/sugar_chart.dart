import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';
import "package:fl_chart/fl_chart.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SugarChart extends StatelessWidget {
  final List<SugarLevelModel> logs;

  const SugarChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Text("No sugar level data found", style: AppTextStyles.title14Grey),
      );
    }

    return Container(
      height: SizeConfig.height * 0.3,
      padding: EdgeInsets.all(SizeConfig.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= logs.length) {
                    return const SizedBox.shrink();
                  }
                  if (value % (logs.length > 5 ? (logs.length / 5).ceil() : 1) != 0) {
                      return const SizedBox.shrink();
                  }
                  final date = logs[value.toInt()].createdAt;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(date),
                      style: AppTextStyles.title12Grey,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: logs.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.level);
              }).toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.redAccent, Colors.orangeAccent],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.withOpacity(0.3),
                    Colors.redAccent.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
