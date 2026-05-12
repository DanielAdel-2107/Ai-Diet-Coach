import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/nutrition/models/nutrition_plan_model.dart';

class MacrosSummaryCard extends StatelessWidget {
  final Macros totalMacros;
  final String objective;

  const MacrosSummaryCard({
    super.key,
    required this.totalMacros,
    required this.objective,
  });

  @override
  Widget build(BuildContext context) {
    double total = totalMacros.protein + totalMacros.carbs + totalMacros.fats;
    double totalCalories =
        (totalMacros.protein * 4) +
        (totalMacros.carbs * 4) +
        (totalMacros.fats * 9);

    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(SizeConfig.width * 0.06),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "AI Goal",
                          style: AppTextStyles.title14BlackW600.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.height * 0.005),
                    SizedBox(
                      width: SizeConfig.width * 0.5,
                      child: Text(
                        objective,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title18BlackBold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${totalCalories.toInt()}",
                        style: AppTextStyles.title20PrimaryColorBold,
                      ),
                      Text("Kcal", style: AppTextStyles.title12Grey),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.height * 0.03),
            Container(height: 1, color: Colors.grey.withOpacity(0.2)),
            SizedBox(height: SizeConfig.height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMacroBar(
                  "Protein",
                  totalMacros.protein,
                  total,
                  AppColors.chartBlue,
                  Icons.fitness_center_rounded,
                ),
                _buildMacroBar(
                  "Carbs",
                  totalMacros.carbs,
                  total,
                  AppColors.chartOrange,
                  Icons.grass_rounded,
                ),
                _buildMacroBar(
                  "Fats",
                  totalMacros.fats,
                  total,
                  AppColors.chartGreen,
                  Icons.water_drop_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(
    String label,
    double value,
    double total,
    Color color,
    IconData icon,
  ) {
    double percent = total > 0 ? (value / total).clamp(0.0, 1.0) : 0;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: SizeConfig.height * 0.01),
          Text("${value.toInt()}g", style: AppTextStyles.title16BlackBold),
          Text(label, style: AppTextStyles.title12Grey),
          SizedBox(height: SizeConfig.height * 0.015),
          LinearPercentIndicator(
            lineHeight: 6,
            percent: percent,
            progressColor: color,
            backgroundColor: color.withOpacity(0.15),
            barRadius: const Radius.circular(3),
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.02),
            animation: true,
            animationDuration: 1500,
          ),
        ],
      ),
    );
  }
}
