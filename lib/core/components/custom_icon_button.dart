import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.icon,
    this.onPressed,
    this.iconColor,
    this.iconSize,
    this.weight,
    this.child,
    this.backgroundColor,
    this.hPadding,
    this.vPadding,
  });

  final IconData? icon;
  final Function()? onPressed;
  final Color? iconColor;
  final Widget? child;
  final double? iconSize;
  final double? weight;
  final Color? backgroundColor;
  final double? hPadding;
  final double? vPadding;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade500,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: hPadding ?? SizeConfig.width * 0.03,
                vertical: vPadding ?? SizeConfig.height * 0.03),
            child: child ??
                Icon(
                  icon,
                  size: iconSize ?? SizeConfig.width * 0.06,
                  color: iconColor ?? Colors.white,
                  weight: weight,
                ),
          ),
        ),
      ),
    );
  }
}
