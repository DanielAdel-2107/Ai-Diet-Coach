import 'package:ai_diet_coach/features/patient/progress/models/progress_models.dart';
import 'package:ai_diet_coach/features/patient/progress/view_models/progress_cubit/progress_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final SupabaseClient _supabase;

  ProgressCubit(this._supabase) : super(ProgressInitial());

  Future<void> fetchProgressData() async {
    emit(ProgressLoading());
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      // Fetch all logs in parallel for better performance
      final results = await Future.wait([
        _supabase
            .from('user_progress')
            .select()
            .eq('user_id', userId)
            .order('recorded_at', ascending: true),
        _supabase
            .from('meals')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: true),
        _supabase
            .from('sugar_levels')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: true),
      ]);

      final weightLogs = (results[0] as List)
          .map((json) => WeightLogModel.fromJson(json))
          .toList();

      final calorieLogs = (results[1] as List)
          .map((json) => CalorieLogModel.fromJson(json))
          .toList();

      final sugarLogs = (results[2] as List)
          .map((json) => SugarLevelModel.fromJson(json))
          .toList();

      emit(ProgressSuccess(
        weightLogs: weightLogs,
        calorieLogs: calorieLogs,
        sugarLogs: sugarLogs,
      ));
    } catch (e) {
      emit(ProgressError("Failed to fetch progress data: ${e.toString()}"));
    }
  }

  Future<void> addWeight(double weight) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final entry = WeightLogModel(
        userId: userId,
        weight: weight,
        createdAt: DateTime.now(),
      );

      await _supabase.from('user_progress').insert(entry.toJson());
      await fetchProgressData();
    } catch (e) {
      emit(ProgressError("Failed to log weight: ${e.toString()}"));
    }
  }

  Future<void> addCalories(int calories, {String? mealType, String? foodName}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      final data = {
        'user_id': userId,
        'calories': calories,
        'meal_type': mealType ?? 'Manual Entry',
        'food_name': foodName ?? 'Logged Meal',
        'meal_date': now.toIso8601String().split('T')[0],
        'created_at': now.toIso8601String(),
      };

      await _supabase.from('meals').insert(data);
      await fetchProgressData();
    } catch (e) {
      emit(ProgressError("Failed to log calories: ${e.toString()}"));
    }
  }

  Future<void> addSugarLevel(double level, String mealTag) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final entry = SugarLevelModel(
        userId: userId,
        level: level,
        mealTag: mealTag,
        createdAt: DateTime.now(),
      );

      await _supabase.from('sugar_levels').insert(entry.toJson());
      await fetchProgressData();
    } catch (e) {
      emit(ProgressError("Failed to log sugar level: ${e.toString()}"));
    }
  }
}
