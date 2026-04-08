import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';

class QuickActionsSection extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onAddMeal;
  final VoidCallback onStartWorkout;

  const QuickActionsSection({
    super.key,
    required this.onScan,
    required this.onAddMeal,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quick Actions",
                style: AppTextStyles.title20BlackBold,
              ),
              Text(
                "See All",
                style: AppTextStyles.title14PrimaryColor,
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.height * 0.02),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
          child: Row(
            children: [
              _buildActionItem(
                "Scan Food",
                "Use camera",
                Icons.center_focus_weak_rounded,
                AppColors.primary,
                AppColors.primaryDark,
                onScan,
                0,
              ),
              SizedBox(width: SizeConfig.width * 0.04),
              _buildActionItem(
                "Saved Meals",
                "View history",
                Icons.history_rounded,
                AppColors.secondary,
                Colors.blue.shade700,
                onAddMeal,
                1,
              ),
              SizedBox(width: SizeConfig.width * 0.04),
              _buildActionItem(
                "Workout",
                "Start session",
                Icons.play_arrow_rounded,
                AppColors.accent,
                Colors.deepOrange,
                onStartWorkout,
                2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String label,
    String subtitle,
    IconData icon,
    Color color1,
    Color color2,
    VoidCallback onTap,
    int index,
  ) {
    return FadeInRight(
      delay: Duration(milliseconds: 200 * index),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: SizeConfig.width * 0.35,
          padding: EdgeInsets.all(SizeConfig.width * 0.04),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color1.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: SizeConfig.width * 0.07),
              ),
              SizedBox(height: SizeConfig.height * 0.02),
              Text(
                label,
                style: AppTextStyles.title16WhiteBold,
              ),
              SizedBox(height: SizeConfig.height * 0.005),
              Text(
                subtitle,
                style: AppTextStyles.title12White70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
