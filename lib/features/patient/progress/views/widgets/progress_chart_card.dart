import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ProgressChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color themeColor;
  final Widget chart;
  final List<Widget>? actions;

  const ProgressChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.chart,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.height * 0.03),
        padding: EdgeInsets.all(SizeConfig.width * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title18BlackBold.copyWith(height: 1),
                    ),
                    SizedBox(height: SizeConfig.height * 0.005),
                    Text(
                      subtitle,
                      style: AppTextStyles.title14Grey,
                    ),
                  ],
                ),
                if (actions != null) ...actions!,
              ],
            ),
            SizedBox(height: SizeConfig.height * 0.03),
            SizedBox(
              height: SizeConfig.height * 0.25,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}
