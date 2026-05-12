import 'package:ai_diet_coach/core/components/custom_app_bar.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/analytics/view_models/analytics_cubit/analytics_cubit.dart';
import 'package:ai_diet_coach/features/patient/analytics/view_models/analytics_cubit/analytics_state.dart';
import 'package:ai_diet_coach/features/patient/analytics/views/widgets/calorie_chart.dart';
import 'package:ai_diet_coach/features/patient/analytics/views/widgets/log_entry_dialog.dart';
import 'package:ai_diet_coach/features/patient/analytics/views/widgets/sugar_chart.dart';
import 'package:ai_diet_coach/features/patient/analytics/views/widgets/weight_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';

class AnalyticsBody extends StatelessWidget {
  const AnalyticsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar(title: "Health Analytics"),
        Expanded(
          child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
            builder: (context, state) {
              if (state is AnalyticsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              } else if (state is AnalyticsSuccess) {
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<AnalyticsCubit>().fetchAnalyticsData(),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(SizeConfig.width * 0.05),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(child: _buildSectionHeader("Weight Progress")),
                        SizedBox(height: SizeConfig.height * 0.02),
                        FadeInRight(child: WeightChart(logs: state.weightLogs)),
                        SizedBox(height: SizeConfig.height * 0.04),
                        
                        FadeInDown(child: _buildSectionHeader("Daily Calorie Intake")),
                        SizedBox(height: SizeConfig.height * 0.02),
                        FadeInRight(child: CalorieChart(logs: state.calorieLogs)),
                        SizedBox(height: SizeConfig.height * 0.04),

                        FadeInDown(child: _buildSectionHeader("Blood Sugar Levels")),
                        SizedBox(height: SizeConfig.height * 0.02),
                        FadeInRight(child: SugarChart(logs: state.sugarLogs)),
                        SizedBox(height: SizeConfig.height * 0.04),
                        
                        FadeInUp(child: _buildLoggingActions(context)),
                        SizedBox(height: SizeConfig.height * 0.04),
                      ],
                    ),
                  ),
                );
              } else if (state is AnalyticsError) {
                // Use CustomQuickAlert for errors as per rules
                WidgetsBinding.instance.addPostFrameCallback((_) {
                   CustomQuickAlert.error(message: state.message);
                });
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () => context.read<AnalyticsCubit>().fetchAnalyticsData(),
                        child: const Text("Retry"),
                      )
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.title18BlackBold);
  }

  Widget _buildLoggingActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            "Log Weight",
            Icons.scale_rounded,
            AppColors.secondary,
            () => _showWeightDialog(context),
          ),
        ),
        SizedBox(width: SizeConfig.width * 0.04),
        Expanded(
          child: _buildActionButton(
            context,
            "Log Calories",
            Icons.fastfood_rounded,
            AppColors.primary,
            () => _showCalorieDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig.width * 0.04),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: SizeConfig.width * 0.05),
        label: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: SizeConfig.width * 0.035,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: SizeConfig.height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.width * 0.04),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showWeightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => LogEntryDialog(
        title: "Log Weight",
        label: "Weight (kg)",
        hint: "Enter weight e.g., 75.5",
        icon: Icons.scale_rounded,
        onSave: (val) {
          final weight = double.tryParse(val);
          if (weight != null) {
            context.read<AnalyticsCubit>().addWeightEntry(weight);
          }
        },
      ),
    );
  }

  void _showCalorieDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => LogEntryDialog(
        title: "Log Calories",
        label: "Calories (kcal)",
        hint: "Enter calories e.g., 500",
        icon: Icons.fastfood_rounded,
        onSave: (val) {
          final calories = int.tryParse(val);
          if (calories != null) {
            context.read<AnalyticsCubit>().addCalorieEntry(calories);
          }
        },
      ),
    );
  }
}
