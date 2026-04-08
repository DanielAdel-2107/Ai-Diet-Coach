import 'package:ai_diet_coach/features/patient/reminders/view_models/reminders_cubit/reminders_cubit.dart';
import 'package:ai_diet_coach/features/patient/reminders/views/widgets/reminders_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RemindersCubit()..loadReminders(),
      child: const Scaffold(
        body: RemindersBody(),
      ),
    );
  }
}
