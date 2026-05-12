import 'dart:math';
import 'package:ai_diet_coach/core/constants/app_constants.dart';
import 'package:ai_diet_coach/core/local_notifications/local_notifications_services.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/features/patient/reminders/models/reminder_model.dart';
import 'package:ai_diet_coach/features/patient/reminders/view_models/reminders_cubit/reminders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemindersCubit extends Cubit<RemindersState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  RemindersCubit() : super(RemindersInitial());

  final List<ReminderModel> _defaultReminders = [
    ReminderModel(
      id: 'workout_reminder',
      title: 'Workout Reminder 🏋️',
      body: 'Time to hit your daily workout goal!',
      isEnabled: false,
      time: const TimeOfDay(hour: 8, minute: 0),
      notificationId: 1001,
      icon: Icons.fitness_center_rounded,
      color: AppColors.primary,
    ),
    ReminderModel(
      id: 'sugar_reminder',
      title: 'Sugar Check 🩸',
      body: "Don't forget to check your sugar level!",
      isEnabled: false,
      time: const TimeOfDay(hour: 10, minute: 0),
      notificationId: 1002,
      icon: Icons.bloodtype_rounded,
      color: AppColors.error,
    ),
    ReminderModel(
      id: 'water_reminder',
      title: 'Hydration Alert 💧',
      body: 'Stay hydrated! Drink a glass of water now.',
      isEnabled: false,
      time: const TimeOfDay(hour: 12, minute: 0),
      notificationId: 1003,
      icon: Icons.water_drop_rounded,
      color: AppColors.secondary,
    ),
  ];

  List<ReminderModel> _reminders = [];

  Future<void> loadReminders() async {
    emit(RemindersLoading());
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        emit(RemindersError("User session lost."));
        return;
      }

      // Fetch from Supabase
      final List<dynamic> data = await _supabase
          .from('reminders')
          .select()
          .eq('user_id', user.id);

      if (data.isEmpty) {
        // Initialize defaults in Supabase
        await _initializeDefaults(user.id);
        
        // Re-fetch to get the Supabase-generated UUIDs
        final List<dynamic> newData = await _supabase
            .from('reminders')
            .select()
            .eq('user_id', user.id);
            
        _reminders = newData.map(_mapSupabaseJsonToModel).toList();
      } else {
        _reminders = data.map(_mapSupabaseJsonToModel).toList();
      }
      
      emit(RemindersLoaded(List.from(_reminders)));
    } catch (e) {
      emit(RemindersError("Sync Error: ${e.toString()}"));
    }
  }

  ReminderModel _mapSupabaseJsonToModel(dynamic json) {
    final String title = json['title'] as String;
    ReminderModel ref;
    if (title.contains('Workout')) ref = _defaultReminders[0];
    else if (title.contains('Sugar')) ref = _defaultReminders[1];
    else ref = _defaultReminders[2];

    return ReminderModel.fromSupabase(
      json,
      ref.icon,
      ref.color,
      ref.notificationId,
    );
  }

  Future<void> _initializeDefaults(String userId) async {
    final List<Map<String, dynamic>> toInsert = _defaultReminders.map((r) {
      final map = r.toJson();
      map.remove('id'); // Remove the local string id since Supabase generates a UUID.
      map['user_id'] = userId;
      return map;
    }).toList();

    await _supabase.from('reminders').insert(toInsert);
  }

  Future<void> toggleReminder(String id, bool isEnabled) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      try {
        final reminder = _reminders[index];
        
        // 1. Request Notification Permissions first if enabling
        if (isEnabled) {
           final granted = await LocalNotificationsServices.requestPermission();
           if (!granted) {
             emit(RemindersError("Notification permission denied."));
             return;
           }
           // Precision: Request exact alarm permission for Android 12+
           await LocalNotificationsServices.requestExactAlarmPermission();
        }

        // 2. Schedule/Cancel Local Notification
        if (isEnabled) {
          final randomBody = _getRandomBody(reminder.title);
          final updatedReminder = reminder.copyWith(isEnabled: true, body: randomBody);
          await _scheduleNotification(updatedReminder);
          // Fire an instant notification as per user request to test/prove it works
          await LocalNotificationsServices.showInstantNotification(
            id: reminder.notificationId,
            title: reminder.title,
            body: randomBody,
          );
        } else {
          await LocalNotificationsServices.cancelNotification(reminder.notificationId);
        }

        // 3. Update Supabase (Logic uses 'title' for mapping back if ID is UUID)
        await _supabase
            .from('reminders')
            .update({'is_active': isEnabled})
            .eq('title', reminder.title);

        _reminders[index] = reminder.copyWith(isEnabled: isEnabled);
        emit(RemindersLoaded(List.from(_reminders)));
      } catch (e) {
        emit(RemindersError("Update failed: ${e.toString()}"));
      }
    }
  }

  Future<void> updateReminderTime(String id, TimeOfDay time) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      try {
        final reminder = _reminders[index];
        final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

        // 1. Update Supabase
        await _supabase
            .from('reminders')
            .update({'reminder_time': timeStr})
            .eq('title', reminder.title);

        _reminders[index] = reminder.copyWith(time: time);

        // 2. Re-schedule if enabled
        if (_reminders[index].isEnabled) {
          final randomBody = _getRandomBody(_reminders[index].title);
          final updatedReminder = _reminders[index].copyWith(body: randomBody);
          await _scheduleNotification(updatedReminder);
        }

        emit(RemindersLoaded(List.from(_reminders)));
      } catch (e) {
        emit(RemindersError("Time update failed."));
      }
    }
  }

  Future<void> _scheduleNotification(ReminderModel reminder) async {
    await LocalNotificationsServices.scheduleDailyNotification(
      id: reminder.notificationId,
      title: reminder.title,
      body: reminder.body,
      time: reminder.time,
    );
  }

  String _getRandomBody(String title) {
    final random = Random();
    if (title.contains('Workout')) {
      return AppConstants.workoutTips[random.nextInt(AppConstants.workoutTips.length)];
    } else if (title.contains('Sugar')) {
      return AppConstants.sugarTips[random.nextInt(AppConstants.sugarTips.length)];
    } else {
      return AppConstants.hydrationTips[random.nextInt(AppConstants.hydrationTips.length)];
    }
  }
}
