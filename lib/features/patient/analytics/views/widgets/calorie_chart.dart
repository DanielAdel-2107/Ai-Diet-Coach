import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/analytics/models/analytics_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalorieChart extends StatelessWidget {
  final List<CalorieLogModel> logs;

  const CalorieChart({super.key, required this.logs});

  Map<String, int> _getDailyAggregates() {
    final Map<String, int> daily = {};
    for (var log in logs) {
      final day = DateFormat('MM/dd').format(log.createdAt);
      daily[day] = (daily[day] ?? 0) + log.calories;
    }
    return daily;
  }

  @override
  Widget build(BuildContext context) {
    final aggregated = _getDailyAggregates();
    if (aggregated.isEmpty) {
      return Center(
        child: Text("No calorie data found", style: AppTextStyles.title14Grey),
      );
    }

    final entries = aggregated.entries.toList();

    return Container(
      height: SizeConfig.height * 0.3,
      padding: EdgeInsets.all(SizeConfig.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= entries.length) return const SizedBox.shrink();
                  if (value % (entries.length > 5 ? (entries.length / 5).ceil() : 1) != 0) {
                      return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      entries[value.toInt()].key,
                      style: AppTextStyles.title12Grey,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: SizeConfig.width * 0.04,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(SizeConfig.width * 0.015),
                    topRight: Radius.circular(SizeConfig.width * 0.015),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
