import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/app_route/route_names.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';

class AIChatCard extends StatelessWidget {
  const AIChatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 800),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, RouteNames.aiChatScreen),
        child: Container(
          padding: EdgeInsets.all(SizeConfig.width * 0.06),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Dark sleek color
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E293B).withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white.withOpacity(0.05),
                  size: SizeConfig.width * 0.4,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.aiGradientStart, AppColors.aiGradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: SizeConfig.width * 0.05),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Health Coach",
                          style: AppTextStyles.title18WhiteBold,
                        ),
                        SizedBox(height: SizeConfig.height * 0.008),
                        Text(
                          "Ask anything about your diet, workouts, or track progress.",
                          style: AppTextStyles.title12White70.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: SizeConfig.width * 0.03),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
