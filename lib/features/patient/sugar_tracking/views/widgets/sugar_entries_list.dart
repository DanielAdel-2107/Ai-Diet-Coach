import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SugarEntriesList extends StatelessWidget {
  final List<SugarLevelModel> levels;

  const SugarEntriesList({super.key, required this.levels});

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) return const SizedBox.shrink();

    // Sort levels by date descending (newest first)
    final sortedLevels = List<SugarLevelModel>.from(levels)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Recent History',
              style: AppTextStyles.title18BlackBold,
            ),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: sortedLevels.take(10).length,
            separatorBuilder: (context, index) =>
                SizedBox(height: SizeConfig.height * 0.015),
            itemBuilder: (context, index) {
              final level = sortedLevels[index];
              final isBeforeMeal = level.mealTag == 'before_meal';

              return FadeInRight(
                delay: Duration(milliseconds: 100 * index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon indicator
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isBeforeMeal
                              ? const Color(0xFFF57C00).withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isBeforeMeal
                              ? Icons.wb_sunny_outlined
                              : Icons.restaurant_rounded,
                          color: isBeforeMeal
                              ? const Color(0xFFF57C00)
                              : AppColors.primaryDark,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Time and tag
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBeforeMeal ? 'Before Meal' : 'After Meal',
                              style: AppTextStyles.title16BlackBold,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd, yyyy • hh:mm a')
                                  .format(level.createdAt),
                              style: AppTextStyles.title12Grey,
                            ),
                          ],
                        ),
                      ),
                      // Value and status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                level.level.toStringAsFixed(0),
                                style: AppTextStyles.title20BlackBold.copyWith(
                                  color: _getValueColor(level.level),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 2, left: 2),
                                child: Text(
                                  ' mg/dL',
                                  style: AppTextStyles.title12Grey.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getValueColor(level.level).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(level.level),
                              style: AppTextStyles.title14BlackBold.copyWith(
                                color: _getValueColor(level.level),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getValueColor(double value) {
    if (value < 70) return AppColors.warning;
    if (value < 100) return AppColors.success;
    if (value < 140) return AppColors.warning;
    return AppColors.error;
  }

  String _getStatusText(double value) {
    if (value < 70) return 'Low';
    if (value < 100) return 'Normal';
    if (value < 140) return 'Elevated';
    return 'High';
  }
}
