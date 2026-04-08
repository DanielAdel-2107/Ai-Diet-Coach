import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.hintText,
    this.lable,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.maxline = 1,
    this.fillColor,
    this.onChanged,
    this.onTap,
    this.enable = true,
    this.keyboardType,
    this.obscureText,
    this.validator,
  });
  final int maxline;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? lable;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final Color? fillColor;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool enable;
  final bool? obscureText;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          validator: validator,
          style: AppTextStyles.title18Black,
          onChanged: onChanged,
          controller: controller,
          onTap: onTap,
          obscureText: obscureText ?? false,
          decoration: InputDecoration(
            label: lable != null ? Text(lable!) : null,
            labelStyle: AppTextStyles.title16PrimaryColorW500,
            enabled: enable,
            fillColor: fillColor ?? Colors.transparent,
            filled: true,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary)
                : null,
            suffixIcon: suffixIcon,
            hintText: hintText,
            hintStyle: AppTextStyles.title16Grey,
            contentPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.width * 0.04,
              vertical: SizeConfig.height * 0.015,
            ),
            border: buildBorder(),
            enabledBorder: buildBorder(),
            focusedBorder: buildBorder(),
          ),
          maxLines: maxline,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  OutlineInputBorder buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.primary),
    );
  }
}
