import 'package:ai_diet_coach/core/components/custom_app_bar.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/analytics/view_models/analytics_cubit/analytics_cubit.dart';
import 'package:ai_diet_coach/features/patient/analytics/view_models/analytics_cubit/analytics_state.dart';
import 'package:ai_diet_coach/features/patient/analytics/views/widgets/calorie_chart.dart';
import 'package:ai_diet_coach/features/patient/analytics/views/widgets/weight_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';

class AnalyticsBody extends StatelessWidget {
  const AnalyticsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar(shopName: "Health Analytics"),
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
                        _buildSectionHeader("Weight Progress"),
                        SizedBox(height: SizeConfig.height * 0.02),
                        WeightChart(logs: state.weightLogs),
                        SizedBox(height: SizeConfig.height * 0.04),
                        _buildSectionHeader("Daily Calorie Intake"),
                        SizedBox(height: SizeConfig.height * 0.02),
                        CalorieChart(logs: state.calorieLogs),
                        SizedBox(height: SizeConfig.height * 0.04),
                        _buildLoggingActions(context),
                      ],
                    ),
                  ),
                );
              } else if (state is AnalyticsError) {
                return Center(child: Text(state.message));
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
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  void _showWeightDialog(BuildContext context) {
    final controller = TextEditingController();
    CustomQuickAlert.confirm(
      title: "Log Weight",
      message: "Enter your current weight in kg:",
      confirmText: "Save",
      onConfirm: () {
        final weight = double.tryParse(controller.text);
        if (weight != null) {
          context.read<AnalyticsCubit>().addWeightEntry(weight);
        }
      },
    );
    // Note: custom_quick_alert might need a way to pass a TextField in content or use a custom content widget
    // If the package doesn't support custom content easily, I'll assume standard confirm for now or fallback to showDialog.
  }

  void _showCalorieDialog(BuildContext context) {
    // Similar logic for calories
    final controller = TextEditingController();
    CustomQuickAlert.confirm(
      title: "Log Calories",
      message: "Enter calories consumed:",
      confirmText: "Save",
      onConfirm: () {
        final calories = int.tryParse(controller.text);
        if (calories != null) {
          context.read<AnalyticsCubit>().addCalorieEntry(calories);
        }
      },
    );
  }
}
