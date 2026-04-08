import 'package:ai_diet_coach/features/patient/reminders/models/reminder_model.dart';

abstract class RemindersState {}

class RemindersInitial extends RemindersState {}

class RemindersLoading extends RemindersState {}

class RemindersLoaded extends RemindersState {
  final List<ReminderModel> reminders;
  RemindersLoaded(this.reminders);
}

class RemindersError extends RemindersState {
  final String message;
  RemindersError(this.message);
}
