import 'package:ai_diet_coach/core/components/custom_elevated_button.dart';
import 'package:ai_diet_coach/core/components/custom_text_form_field_with_title.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class LogEntryDialog extends StatefulWidget {
  final String title;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final Function(String) onSave;

  const LogEntryDialog({
    super.key,
    required this.title,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onSave,
    this.keyboardType = TextInputType.number,
  });

  @override
  State<LogEntryDialog> createState() => _LogEntryDialogState();
}

class _LogEntryDialogState extends State<LogEntryDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.08),
      child: Container(
        padding: EdgeInsets.all(SizeConfig.width * 0.06),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: AppColors.primary, size: 32),
            ),
            SizedBox(height: SizeConfig.height * 0.02),
            Text(widget.title, style: AppTextStyles.title20BlackBold),
            SizedBox(height: SizeConfig.height * 0.03),
            CustomTextFormFieldWithTitle(
              title: widget.label,
              labelText: widget.hint,
              controller: _controller,
              keyboardType: widget.keyboardType,
              prefixIcon: widget.icon,
            ),
            SizedBox(height: SizeConfig.height * 0.04),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: AppTextStyles.title16GreyW500,
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.width * 0.04),
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        widget.onSave(_controller.text);
                        Navigator.pop(context);
                      }
                    },
                    name: "Save",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
