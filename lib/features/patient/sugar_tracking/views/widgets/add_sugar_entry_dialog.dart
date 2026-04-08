import 'package:ai_diet_coach/core/components/custom_elevated_button.dart';
import 'package:ai_diet_coach/core/components/custom_text_form_field.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/view_models/sugar_cubit/sugar_cubit.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddSugarEntryDialog extends StatefulWidget {
  const AddSugarEntryDialog({super.key});

  @override
  State<AddSugarEntryDialog> createState() => _AddSugarEntryDialogState();
}

class _AddSugarEntryDialogState extends State<AddSugarEntryDialog> {
  final TextEditingController _levelController = TextEditingController();
  String _selectedTag = 'before_meal';

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.card,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.width * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add Sugar Level", style: AppTextStyles.title18BlackBold),
            SizedBox(height: SizeConfig.height * 0.03),
            CustomTextFormField(
              controller: _levelController,
              hintText: "Enter Level (mg/dL)",
              keyboardType: TextInputType.number,
              prefixIcon: Icons.monitor_heart_rounded,
            ),
            SizedBox(height: SizeConfig.height * 0.02),
            Row(
              children: [
                _buildTagChip('before_meal', "Before Meal"),
                SizedBox(width: SizeConfig.width * 0.02),
                _buildTagChip('after_meal', "After Meal"),
              ],
            ),
            SizedBox(height: SizeConfig.height * 0.03),
            CustomElevatedButton(
              onPressed: () {
                final levelText = _levelController.text.trim();
                if (levelText.isEmpty) {
                  CustomQuickAlert.error(
                    title: 'Empty Input',
                    message: 'Please enter a sugar level.',
                  );
                  return;
                }

                final level = double.tryParse(levelText);
                if (level == null || level <= 0) {
                  CustomQuickAlert.error(
                    title: 'Invalid Input',
                    message: 'Please enter a valid sugar level greater than 0.',
                  );
                  return;
                }
                
                // Hide keyboard
                FocusScope.of(context).unfocus();
                
                // Trigger add (feedback handled by SugarTrackingBody listener)
                context.read<SugarCubit>().addSugarLevel(level, _selectedTag);
                
                // Close dialog
                Navigator.pop(context);
              },
              name: "Save Record",
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag, String label) {
    final isSelected = _selectedTag == tag;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTag = tag),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
