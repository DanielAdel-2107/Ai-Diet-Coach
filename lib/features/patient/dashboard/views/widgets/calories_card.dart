import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';

class CaloriesCard extends StatelessWidget {
  final double current;
  final double goal;

  const CaloriesCard({
    super.key,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = (current / goal).clamp(0.0, 1.0);
    
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: EdgeInsets.all(SizeConfig.width * 0.06),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: SizeConfig.width * 0.16,
              lineWidth: 14.0,
              percent: percentage,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: AppColors.accent, size: 28),
                  SizedBox(height: SizeConfig.height * 0.005),
                  Text(
                    "${(percentage * 100).toInt()}%",
                    style: AppTextStyles.title18BlackBold,
                  ),
                ],
              ),
              progressColor: AppColors.accent,
              backgroundColor: AppColors.accent.withOpacity(0.15),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1500,
            ),
            SizedBox(width: SizeConfig.width * 0.06),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Calories Today",
                    style: AppTextStyles.title16GreyW500,
                  ),
                  SizedBox(height: SizeConfig.height * 0.01),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        current.toInt().toString(),
                        style: AppTextStyles.title32BlackBold.copyWith(color: AppColors.textPrimary),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 4),
                        child: Text(
                          "/ ${goal.toInt()} kcal",
                          style: AppTextStyles.title14Grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.height * 0.015),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "🔥 Keep going! You're doing great.",
                      style: AppTextStyles.title12PrimaryColorW500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
