import 'dart:math' as math;

import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';
import 'package:flutter/material.dart';

class SugarStatsHeader extends StatefulWidget {
  final List<SugarLevelModel> levels;
  final double average;

  const SugarStatsHeader({
    super.key,
    required this.levels,
    required this.average,
  });

  @override
  State<SugarStatsHeader> createState() => _SugarStatsHeaderState();
}

class _SugarStatsHeaderState extends State<SugarStatsHeader>
    with TickerProviderStateMixin {
  late AnimationController _gaugeController;
  late Animation<double> _gaugeAnimation;

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _gaugeAnimation = CurvedAnimation(
      parent: _gaugeController,
      curve: Curves.easeOutCubic,
    );
    _gaugeController.forward();
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    super.dispose();
  }

  double get _beforeAverage {
    final before = widget.levels
        .where((l) => l.mealTag == 'before_meal')
        .map((l) => l.level)
        .toList();
    if (before.isEmpty) return 0;
    return before.reduce((a, b) => a + b) / before.length;
  }

  double get _afterAverage {
    final after = widget.levels
        .where((l) => l.mealTag == 'after_meal')
        .map((l) => l.level)
        .toList();
    if (after.isEmpty) return 0;
    return after.reduce((a, b) => a + b) / after.length;
  }

  String get _statusLabel {
    if (widget.average == 0) return 'No Data';
    if (widget.average < 70) return 'Low';
    if (widget.average < 100) return 'Normal';
    if (widget.average < 126) return 'Pre-diabetic';
    return 'High';
  }

  Color get _statusColor {
    if (widget.average == 0) return AppColors.textSecondary;
    if (widget.average < 70) return AppColors.warning;
    if (widget.average < 100) return AppColors.success;
    if (widget.average < 126) return AppColors.warning;
    return AppColors.error;
  }

  // 0–300 mg/dL mapped to 0–1 gauge
  double get _gaugeValue => (widget.average / 300).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
      child: Column(
        children: [
          // Main Gauge Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(SizeConfig.width * 0.06),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
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
                        Text(
                          'Average Level',
                          style: AppTextStyles.title14Grey.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                        SizedBox(height: SizeConfig.height * 0.005),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.average == 0
                                  ? '--'
                                  : widget.average.toStringAsFixed(0),
                              style: AppTextStyles.title32BlackBold.copyWith(
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5, left: 4),
                              child: Text(
                                'mg/dL',
                                style: AppTextStyles.title14Grey.copyWith(
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _statusColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _statusLabel,
                            style: AppTextStyles.title14BlackBold.copyWith(
                              color: _statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.height * 0.025),
                // Animated gauge bar
                AnimatedBuilder(
                  animation: _gaugeAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              FractionallySizedBox(
                                widthFactor:
                                    _gaugeValue * _gaugeAnimation.value,
                                child: Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.success,
                                        AppColors.warning,
                                        AppColors.error,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: SizeConfig.height * 0.008),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '70',
                              style: AppTextStyles.title12Grey.copyWith(
                                color: Colors.white38,
                              ),
                            ),
                            Text(
                              'Normal: 70–99',
                              style: AppTextStyles.title12Grey.copyWith(
                                color: Colors.white38,
                              ),
                            ),
                            Text(
                              '300',
                              style: AppTextStyles.title12Grey.copyWith(
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: SizeConfig.height * 0.025),
                // Total readings count
                Row(
                  children: [
                    _buildMiniStat(
                      icon: Icons.format_list_numbered_rounded,
                      label: 'Total Readings',
                      value: widget.levels.length.toString(),
                      color: AppColors.chartBlue,
                    ),
                    SizedBox(width: SizeConfig.width * 0.03),
                    _buildMiniStat(
                      icon: Icons.trending_up_rounded,
                      label: 'Highest',
                      value: widget.levels.isEmpty
                          ? '--'
                          : widget.levels
                              .map((l) => l.level)
                              .reduce(math.max)
                              .toStringAsFixed(0),
                      color: AppColors.chartOrange,
                    ),
                    SizedBox(width: SizeConfig.width * 0.03),
                    _buildMiniStat(
                      icon: Icons.trending_down_rounded,
                      label: 'Lowest',
                      value: widget.levels.isEmpty
                          ? '--'
                          : widget.levels
                              .map((l) => l.level)
                              .reduce(math.min)
                              .toStringAsFixed(0),
                      color: AppColors.chartGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: SizeConfig.height * 0.02),
          // Before/After meal cards
          Row(
            children: [
              Expanded(
                child: _buildMealCard(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Before Meal',
                  value: _beforeAverage == 0
                      ? '--'
                      : _beforeAverage.toStringAsFixed(0),
                  gradientColors: [
                    const Color(0xFFFFF3E0),
                    const Color(0xFFFFE0B2),
                  ],
                  iconColor: const Color(0xFFF57C00),
                  valueColor: const Color(0xFFE65100),
                ),
              ),
              SizedBox(width: SizeConfig.width * 0.03),
              Expanded(
                child: _buildMealCard(
                  icon: Icons.restaurant_rounded,
                  label: 'After Meal',
                  value: _afterAverage == 0
                      ? '--'
                      : _afterAverage.toStringAsFixed(0),
                  gradientColors: [
                    const Color(0xFFE8F5E9),
                    const Color(0xFFC8E6C9),
                  ],
                  iconColor: AppColors.primaryDark,
                  valueColor: const Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.title16BlackBold.copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.title12Grey.copyWith(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradientColors,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.width * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          SizedBox(height: SizeConfig.height * 0.012),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.title24BlackBold.copyWith(
                  color: valueColor,
                  letterSpacing: -0.5,
                ),
              ),
              if (value != '--')
                Padding(
                  padding: const EdgeInsets.only(bottom: 3, left: 2),
                  child: Text(
                    ' mg/dL',
                    style: AppTextStyles.title12Grey.copyWith(
                      color: valueColor.withOpacity(0.6),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: SizeConfig.height * 0.005),
          Text(
            label,
            style: AppTextStyles.title12Grey.copyWith(
              color: valueColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
