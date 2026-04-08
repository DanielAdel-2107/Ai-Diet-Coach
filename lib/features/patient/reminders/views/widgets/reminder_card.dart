import 'package:animate_do/animate_do.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/reminders/models/reminder_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final Function(bool) onToggle;
  final VoidCallback onTimeTap;
  final int index;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onTimeTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.height * 0.02),
        padding: EdgeInsets.all(SizeConfig.width * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: reminder.color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: reminder.isEnabled
                ? reminder.color.withOpacity(0.1)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            _buildIcon(),
            SizedBox(width: SizeConfig.width * 0.05),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.title, style: AppTextStyles.title18BlackBold),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: onTimeTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reminder.time.format(context),
                            style: AppTextStyles.title14PrimaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: reminder.isEnabled,
              onChanged: onToggle,
              activeColor: reminder.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            reminder.color.withOpacity(0.2),
            reminder.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(reminder.icon, color: reminder.color, size: 28),
    );
  }
}
