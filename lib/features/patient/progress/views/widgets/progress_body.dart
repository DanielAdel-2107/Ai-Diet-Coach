import 'package:ai_diet_coach/core/components/custom_app_bar.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/analytics/views/widgets/log_entry_dialog.dart';
import 'package:ai_diet_coach/features/patient/progress/models/progress_models.dart';
import 'package:ai_diet_coach/features/patient/progress/view_models/progress_cubit/progress_cubit.dart';
import 'package:ai_diet_coach/features/patient/progress/view_models/progress_cubit/progress_state.dart';
import 'package:ai_diet_coach/features/patient/progress/views/widgets/progress_chart_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';

class ProgressBody extends StatelessWidget {
  const ProgressBody({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(title: "My Progress"),
          Expanded(
            child: BlocBuilder<ProgressCubit, ProgressState>(
              builder: (context, state) {
                if (state is ProgressLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } else if (state is ProgressSuccess) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<ProgressCubit>().fetchProgressData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.height * 0.02),
                          _buildSummaryGrid(state),
                          SizedBox(height: SizeConfig.height * 0.04),
                          _buildWeightChart(state.weightLogs),
                          _buildCalorieChart(state.calorieLogs),
                          _buildWorkoutChart(state.workoutLogs),
                          _buildSugarChart(state.sugarLogs),
                          SizedBox(height: SizeConfig.height * 0.05),
                        ],
                      ),
                    ),
                  );
                } else if (state is ProgressError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    CustomQuickAlert.error(message: state.message);
                  });
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.withOpacity(0.5)),
                        SizedBox(height: SizeConfig.height * 0.02),
                        Text("Oops! Something went wrong", style: AppTextStyles.title18BlackBold),
                        SizedBox(height: SizeConfig.height * 0.01),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(state.message, textAlign: TextAlign.center, style: AppTextStyles.title14Grey),
                        ),
                        ElevatedButton(
                          onPressed: () => context.read<ProgressCubit>().fetchProgressData(),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text("Retry Connection", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildMultiFloatingActionButton(context),
    );
  }

  Widget _buildMultiFloatingActionButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: "sugar",
          onPressed: () => _showAddSugarDialog(context),
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.bloodtype_rounded, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          heroTag: "calorie",
          onPressed: () => _showAddCalorieDialog(context),
          backgroundColor: AppColors.secondary,
          child: const Icon(Icons.fastfood_rounded, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "weight",
          onPressed: () => _showAddWeightDialog(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.scale_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(ProgressSuccess state) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildSummaryCard(
            "Current Weight",
            "${state.latestWeight?.weight ?? '--'} kg",
            state.weightChange > 0 ? "+${state.weightChange.toStringAsFixed(1)}" : state.weightChange.toStringAsFixed(1),
            state.weightChange <= 0 ? Colors.green : Colors.red,
            Icons.scale_rounded,
            AppColors.primary,
          ),
          _buildSummaryCard(
            "Sugar Level",
            "${state.latestSugar?.level ?? '--'} mg/dL",
            state.latestSugar?.mealTag ?? "N/A",
            AppColors.accent,
            Icons.bloodtype_rounded,
            AppColors.accent,
          ),
          _buildSummaryCard(
            "Active Burn",
            "${state.totalCaloriesBurned.toInt()} kcal",
            "Burned today",
            Colors.orange,
            Icons.local_fire_department_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String trend, Color trendColor, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.title14Grey),
          SizedBox(height: SizeConfig.height * 0.005),
          FittedBox(
            child: Text(
              value,
              style: AppTextStyles.title18BlackBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(List<WeightLogModel> logs) {
    if (logs.isEmpty) return _buildEmptyChart("Weight");

    final spots = logs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    return ProgressChartCard(
      title: "Weight Trend",
      subtitle: "Showing progress over ${logs.length} entries",
      themeColor: AppColors.primary,
      chart: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: AppColors.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
             touchTooltipData: LineTouchTooltipData(
               getTooltipColor: (_) => AppColors.primary,
               getTooltipItems: (touchedSpots) {
                 return touchedSpots.map((spot) {
                   return LineTooltipItem(
                     "${spot.y} kg",
                     const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                   );
                 }).toList();
               },
             ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieChart(List<CalorieLogModel> logs) {
    if (logs.isEmpty) return _buildEmptyChart("Calories");

    final bars = logs.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.calories.toDouble(),
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 3000,
              color: AppColors.secondary.withOpacity(0.05),
            ),
          ),
        ],
      );
    }).toList();

    return ProgressChartCard(
      title: "Daily Nutrition",
      subtitle: "Recent calorie intake overview",
      themeColor: AppColors.secondary,
      chart: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: bars,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.secondary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                 return BarTooltipItem(
                   "${rod.toY.toInt()} kcal",
                   const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                 );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSugarChart(List<SugarLevelModel> logs) {
    if (logs.isEmpty) return _buildEmptyChart("Sugar");

    final spots = logs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.level);
    }).toList();

    return ProgressChartCard(
      title: "Glucose Tracking",
      subtitle: "Monitoring daily peaks and lows",
      themeColor: AppColors.accent,
      chart: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.4,
              color: AppColors.accent,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.accent,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.25),
                    AppColors.accent.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.accent,
              getTooltipItems: (touchedSpots) {
                 return touchedSpots.map((spot) {
                   return LineTooltipItem(
                     "${spot.y} mg/dL",
                     const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                   );
                 }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutChart(List<WorkoutLogModel> logs) {
    if (logs.isEmpty) return _buildEmptyChart("Workout");

    final spots = logs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.caloriesBurned);
    }).toList();

    return ProgressChartCard(
      title: "Exercise Burn",
      subtitle: "Calories burned during activities",
      themeColor: Colors.orange,
      chart: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => LogEntryDialog(
        title: "Log Weight",
        label: "Weight (kg)",
        hint: "Enter your current weight",
        icon: Icons.scale_rounded,
        onSave: (val) {
          final weight = double.tryParse(val);
          if (weight != null) {
            context.read<ProgressCubit>().logWeight(weight);
          }
        },
      ),
    );
  }

  void _showAddCalorieDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => LogEntryDialog(
        title: "Log Calories",
        label: "Calories (kcal)",
        hint: "Enter calories consumed",
        icon: Icons.fastfood_rounded,
        onSave: (val) {
          final calories = int.tryParse(val);
          if (calories != null) {
            context.read<ProgressCubit>().logCalorie(calories);
          }
        },
      ),
    );
  }

  void _showAddSugarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => LogEntryDialog(
        title: "Log Sugar",
        label: "Level (mg/dL)",
        hint: "Enter blood sugar level",
        icon: Icons.bloodtype_rounded,
        onSave: (val) {
          final level = double.tryParse(val);
          if (level != null) {
            context.read<ProgressCubit>().logSugar(level, "Manual Log");
          }
        },
      ),
    );
  }

  Widget _buildEmptyChart(String label) {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, color: AppColors.border, size: 40),
            const SizedBox(height: 12),
            Text("No $label data yet", style: AppTextStyles.title14Grey),
          ],
        ),
      ),
    );
  }
}
