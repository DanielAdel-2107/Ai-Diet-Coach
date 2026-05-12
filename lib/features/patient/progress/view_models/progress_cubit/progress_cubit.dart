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
      if (userId == null) {
        emit(ProgressError("User not logged in"));
        return;
      }

      // Helper to fetch with fallback columns
      Future<List<Map<String, dynamic>>> fetchWithFallback(String table, List<String> columns) async {
        for (var col in columns) {
          try {
            return await _supabase.from(table).select().eq('user_id', userId).order(col, ascending: true);
          } catch (_) {
            if (col == columns.last) rethrow;
          }
        }
        return [];
      }

      final results = await Future.wait([
        fetchWithFallback('weight_logs', ['created_at', 'recorded_at']),
        _supabase.from('calorie_logs').select().eq('user_id', userId).order('created_at', ascending: true).catchError((_) {
            return _supabase.from('meals').select().eq('user_id', userId).order('created_at', ascending: true);
        }).catchError((_) {
            return _supabase.from('meals').select().eq('user_id', userId).order('meal_date', ascending: true);
        }),
        fetchWithFallback('sugar_levels', ['created_at']),
        fetchWithFallback('workout_logs', ['created_at', 'completed_at']),
      ]);

      final weightLogs = (results[0] as List).map((json) => WeightLogModel.fromJson(json)).toList();
      final rawCalories = (results[1] as List).map((json) => CalorieLogModel.fromJson(json)).toList();
      final sugarLogs = (results[2] as List).map((json) => SugarLevelModel.fromJson(json)).toList();
      final workoutLogs = (results[3] as List).map((json) => WorkoutLogModel.fromJson(json)).toList();

      // Group calories by date
      final Map<String, double> groupedCalories = {};
      for (var log in rawCalories) {
        final dateKey = log.createdAt.toIso8601String().split('T')[0];
        groupedCalories[dateKey] = (groupedCalories[dateKey] ?? 0) + log.calories;
      }

      final calorieLogs = groupedCalories.entries.map((e) => CalorieLogModel(
        userId: userId,
        calories: e.value.toInt(),
        createdAt: DateTime.parse(e.key),
      )).toList();

      emit(ProgressSuccess(
        weightLogs: weightLogs,
        calorieLogs: calorieLogs,
        sugarLogs: sugarLogs,
        workoutLogs: workoutLogs,
      ));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> logWeight(double weight) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      await _supabase.from('weight_logs').insert({'user_id': userId, 'weight': weight});
      await fetchProgressData();
    } catch (e) {
      emit(ProgressError("Failed to save weight: $e"));
    }
  }

  Future<void> logCalorie(int calories) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase.from('calorie_logs').insert({'user_id': userId, 'calories': calories});
      await fetchProgressData();
    } catch (e) {
      try {
        await _supabase.from('meals').insert({
          'user_id': userId,
          'calories': calories,
          'meal_date': DateTime.now().toIso8601String()
        });
        await fetchProgressData();
      } catch (e2) {
        emit(ProgressError("Failed to save calories: $e2"));
      }
    }
  }

  Future<void> logSugar(double level, String tag) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      await _supabase.from('sugar_levels').insert({'user_id': userId, 'level': level, 'meal_tag': tag});
      await fetchProgressData();
    } catch (e) {
      emit(ProgressError("Failed to save sugar level: $e"));
    }
  }

  Future<void> refresh() => fetchProgressData();
}
