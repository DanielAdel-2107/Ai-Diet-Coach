import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/nutrition/models/nutrition_plan_model.dart';

class MealSectionCard extends StatelessWidget {
  final MealDetail meal;
  final int index;

  const MealSectionCard({
    super.key,
    required this.meal,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = _getMealIcon(meal.type);
    Color color = _getMealColor(meal.type);
    Color lightColor = _getMealLightColor(meal.type);

    return FadeInUp(
      delay: Duration(milliseconds: 200 * index),
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.height * 0.025),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Decorative background shape
              Positioned(
                right: -30,
                top: -30,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: lightColor.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(SizeConfig.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                        SizedBox(width: SizeConfig.width * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.type.toUpperCase(),
                                style: AppTextStyles.title12Grey.copyWith(
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              SizedBox(height: SizeConfig.height * 0.005),
                              Text(
                                "${meal.calories.toInt()} kcal",
                                style: AppTextStyles.title18BlackBold,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                      ],
                    ),
                    SizedBox(height: SizeConfig.height * 0.02),
                    Text(
                      meal.name,
                      style: AppTextStyles.title18BlackW600,
                    ),
                    SizedBox(height: SizeConfig.height * 0.015),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: meal.ingredients.map((ing) => _buildChip(ing, color)).toList(),
                    ),
                    SizedBox(height: SizeConfig.height * 0.02),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _buildMacroRow(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildMacroRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMacroItem("Protein", "${meal.macros.protein}g", AppColors.chartBlue),
        _buildMacroItem("Carbs", "${meal.macros.carbs}g", AppColors.chartOrange),
        _buildMacroItem("Fats", "${meal.macros.fats}g", AppColors.chartGreen),
      ],
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            text: "$label: ",
            style: AppTextStyles.title12Grey,
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getMealIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast': return Icons.free_breakfast_rounded;
      case 'lunch': return Icons.lunch_dining_rounded;
      case 'dinner': return Icons.dinner_dining_rounded;
      case 'snacks':
      case 'snack': return Icons.cookie_rounded;
      default: return Icons.fastfood_rounded;
    }
  }

  Color _getMealColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast': return const Color(0xFFF59E0B); // Amber
      case 'lunch': return const Color(0xFF10B981); // Emerald
      case 'dinner': return const Color(0xFF6366F1); // Indigo
      case 'snacks':
      case 'snack': return const Color(0xFFEC4899); // Pink
      default: return AppColors.primary;
    }
  }
  
  Color _getMealLightColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast': return const Color(0xFFFEF3C7);
      case 'lunch': return const Color(0xFFD1FAE5);
      case 'dinner': return const Color(0xFFE0E7FF);
      case 'snacks':
      case 'snack': return const Color(0xFFFCE7F3);
      default: return AppColors.primaryLight;
    }
  }
}
