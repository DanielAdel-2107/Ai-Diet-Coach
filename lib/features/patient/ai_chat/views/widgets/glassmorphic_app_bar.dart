import 'dart:ui';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class GlassmorphicAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget? leading;
  final List<Widget>? actions;

  const GlassmorphicAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 15,
            left: 10,
            right: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
          child: Row(
            children: [
              leading ?? 
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
              const SizedBox(width: 5),
              Stack(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.aiGradientStart,
                          AppColors.aiGradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.aiGradientStart.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppTextStyles.title18BlackBold, overflow: TextOverflow.ellipsis),
                    Text(subtitle, style: AppTextStyles.title12GreyShade600, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (actions != null) ...actions!
              else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "PRO",
                    style: AppTextStyles.label13WhiteW600.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
