import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/view_models/workout_plan_cubit/workout_plan_state.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/models/workout_plan_model.dart';

class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  final GeminiService service;
  final SupabaseClient _supabase = Supabase.instance.client;

  WorkoutPlanCubit(this.service) : super(WorkoutPlanInitial());

  // --- Fetch Saved Plan from Supabase ---
  Future<void> loadSavedPlan() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    emit(WorkoutPlanLoading());
    try {
      final response = await _supabase
          .from('workout_plans')
          .select()
          .eq('user_id', user.id)
          .order('day_of_week', ascending: true);

      if (response.isNotEmpty) {
        final plan = WorkoutPlanModel.fromSupabase(response);
        emit(WorkoutPlanLoaded(plan));
      } else {
        emit(WorkoutPlanInitial());
      }
    } catch (e) {
      emit(WorkoutPlanFailure("Failed to load plan: ${e.toString()}"));
    }
  }

  // --- Generate and Save Plan ---
  Future<void> generateAndSavePlan() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      emit(WorkoutPlanFailure("User not authenticated"));
      return;
    }

    emit(WorkoutPlanLoading());
    try {
      // 1. Fetch User Profile for data
      final profile = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      final int age = profile['age'] ?? 25;
      final double weight = (profile['weight'] ?? 70).toDouble();
      final double height = (profile['height'] ?? 175).toDouble();
      final String goal = profile['goal'] ?? "Fitness";

      // 2. Generate via Gemini
      final plan = await service.generateWorkoutPlan(
        age: age,
        weight: weight,
        height: height,
        goal: goal,
      );

      // 3. Save to Supabase (Batch)
      await _savePlanToSupabase(user.id, plan);

      emit(WorkoutPlanLoaded(plan));
    } catch (e) {
      emit(WorkoutPlanFailure("Generation failed: ${e.toString()}"));
    }
  }

  Future<void> _savePlanToSupabase(String userId, WorkoutPlanModel plan) async {
    // Clear old plan first
    await _supabase.from('workout_plans').delete().eq('user_id', userId);

    final List<Map<String, dynamic>> rows = [];
    for (var day in plan.days) {
      if (day.isRestDay) {
        rows.add({
          'user_id': userId,
          'day_of_week': day.day,
          'focus': day.focus,
          'is_rest_day': true,
          'exercise_name': "Rest",
        });
      } else {
        for (var exercise in day.exercises) {
          rows.add(exercise.toSupabase(userId, day.day, day.focus, false));
        }
      }
    }

    if (rows.isNotEmpty) {
      await _supabase.from('workout_plans').insert(rows);
    }
  }

  // --- UI State Management ---
  void selectDay(int index) {
    if (state is WorkoutPlanLoaded) {
      final currentState = state as WorkoutPlanLoaded;
      emit(WorkoutPlanLoaded(currentState.plan, selectedDayIndex: index));
    }
  }

  // Helper for manual generate if initial state
  Future<void> generatePlan({
    required int age,
    required double weight,
    required double height,
    required String goal,
  }) async {
    emit(WorkoutPlanLoading());
    try {
      final plan = await service.generateWorkoutPlan(
        age: age,
        weight: weight,
        height: height,
        goal: goal,
      );
      
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _savePlanToSupabase(user.id, plan);
      }
      
      emit(WorkoutPlanLoaded(plan));
    } catch (e) {
      emit(WorkoutPlanFailure(e.toString()));
    }
  }
}
