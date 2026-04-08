import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:flutter/material.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';

class CustomElevatedButtonWithIcon extends StatelessWidget {
  const CustomElevatedButtonWithIcon({
    super.key,
    required this.title,
    this.onPressed,
    this.icon,
    this.textStyle,
    this.image,
    this.backgroundColor,
    this.iconAlignment,
    this.height,
    this.width,
  });
  final String title;
  final Function()? onPressed;
  final TextStyle? textStyle;
  final String? image;
  final IconData? icon;
  final Color? backgroundColor;
  final IconAlignment? iconAlignment;
  final double? height, width;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.width * 0.06,
              vertical: SizeConfig.height * 0.01),
          minimumSize: (height != null && width != null)
              ? Size(width!, height!)
              : Size(double.infinity, SizeConfig.height * 0.07),
        ),
        iconAlignment: iconAlignment ?? IconAlignment.end,
        onPressed: onPressed,
        icon: image != null
            ? Image.asset(
                image!,
                width: SizeConfig.width * 0.1,
              )
            : Icon(
                icon,
                color: Colors.white,
              ),
        label: Text(
          title,
          style: textStyle ?? AppTextStyles.title18WhiteW500,
        ),
      ),
    );
  }
}
