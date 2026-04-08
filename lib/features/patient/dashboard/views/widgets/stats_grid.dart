import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';

class StatsGrid extends StatelessWidget {
  final String workoutPlan;
  final String nutritionPlan;
  final double sugarLevel;
  final String sugarStatus;
  final VoidCallback? onWorkoutTap;
  final VoidCallback? onNutritionTap;
  final VoidCallback? onSugarTap;
  final VoidCallback? onMoreInfoTap;

  const StatsGrid({
    super.key,
    required this.workoutPlan,
    required this.nutritionPlan,
    required this.sugarLevel,
    required this.sugarStatus,
    this.onWorkoutTap,
    this.onNutritionTap,
    this.onSugarTap,
    this.onMoreInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Health Overview",
          style: AppTextStyles.title20BlackBold,
        ),
        SizedBox(height: SizeConfig.height * 0.02),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: SizeConfig.width * 0.04,
          mainAxisSpacing: SizeConfig.width * 0.04,
          childAspectRatio: 1.0, 
          children: [
            _buildStatCard(
              "Workout",
              workoutPlan,
              Icons.fitness_center_rounded,
              AppColors.secondary,
              1,
              onTap: onWorkoutTap,
            ),
            _buildStatCard(
              "Nutrition",
              nutritionPlan,
              Icons.restaurant_menu_rounded,
              AppColors.primaryDark,
              2,
              onTap: onNutritionTap,
            ),
            _buildStatCard(
              "Sugar Level",
              "$sugarLevel mg/dL",
              Icons.bloodtype_rounded,
              AppColors.error,
              3,
              subtitle: sugarStatus,
              onTap: onSugarTap,
            ),
            _buildStatCard(
              "More Info",
              "Check details",
              Icons.dashboard_customize_rounded,
              AppColors.warning,
              4,
              onTap: onMoreInfoTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    int index, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: 200 * index),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(SizeConfig.width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: SizeConfig.width * 0.06),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title12Grey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeConfig.height * 0.005),
                  Text(
                    value,
                    style: AppTextStyles.title16BlackBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: SizeConfig.height * 0.005),
                    Text(
                      subtitle,
                      style: AppTextStyles.title12PrimaryColorW500.copyWith(
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
