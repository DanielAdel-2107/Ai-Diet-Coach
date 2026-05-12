import 'package:animate_do/animate_do.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:ai_diet_coach/features/patient/reminders/view_models/reminders_cubit/reminders_cubit.dart';
import 'package:ai_diet_coach/features/patient/reminders/view_models/reminders_cubit/reminders_state.dart';
import 'package:ai_diet_coach/features/patient/reminders/views/widgets/reminder_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemindersBody extends StatelessWidget {
  const RemindersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RemindersCubit, RemindersState>(
      listener: (context, state) {
        if (state is RemindersError) {
          CustomQuickAlert.error(title: "Oops!", message: state.message);
        }
      },
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<RemindersCubit, RemindersState>(
              builder: (context, state) {
                if (state is RemindersLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } else if (state is RemindersLoaded) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.width * 0.05,
                      vertical: 20,
                    ),
                    itemCount: state.reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = state.reminders[index];
                      return ReminderCard(
                        reminder: reminder,
                        index: index,
                        onToggle: (val) {
                          context.read<RemindersCubit>().toggleReminder(reminder.id, val);
                        },
                        onTimeTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: reminder.time,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            if (context.mounted) {
                              context.read<RemindersCubit>().updateReminderTime(reminder.id, picked);
                            }
                          }
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: SizeConfig.width * 0.05,
        right: SizeConfig.width * 0.05,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FadeInLeft(
            child: Text(
              "Health Reminders",
              style: AppTextStyles.title28BlackW700,
            ),
          ),
          const SizedBox(height: 8),
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Text(
              "Never miss a goal. Stay on track today!",
              style: AppTextStyles.title14Grey,
            ),
          ),
        ],
      ),
    );
  }
}
