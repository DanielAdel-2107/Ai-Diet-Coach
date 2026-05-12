import 'package:ai_diet_coach/features/patient/analytics/models/analytics_models.dart';
import 'package:ai_diet_coach/features/patient/analytics/view_models/analytics_cubit/analytics_state.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final SupabaseClient _supabase;

  AnalyticsCubit(this._supabase) : super(AnalyticsInitial());

  Future<void> fetchAnalyticsData() async {
    emit(AnalyticsLoading());
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      // Fetch all logs in parallel for better performance
      final results = await Future.wait([
        _supabase.from('weight_logs').select().eq('user_id', userId).order('created_at', ascending: true),
        _supabase.from('calorie_logs').select().eq('user_id', userId).order('created_at', ascending: true),
        _supabase.from('sugar_levels').select().eq('user_id', userId).order('created_at', ascending: true),
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

      emit(AnalyticsSuccess(
        weightLogs: weightLogs,
        calorieLogs: calorieLogs,
        sugarLogs: sugarLogs,
      ));
    } catch (e) {
      emit(AnalyticsError("Connection Error: ${e.toString()}"));
    }
  }

  Future<void> addWeightEntry(double weight) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final entry = WeightLogModel(
        userId: userId,
        weight: weight,
        createdAt: DateTime.now(),
      );

      await _supabase.from('weight_logs').insert(entry.toJson());
      await fetchAnalyticsData();
    } catch (e) {
      emit(AnalyticsError("Failed to add weight: ${e.toString()}"));
    }
  }

  Future<void> addCalorieEntry(int calories, {String? mealType}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final entry = CalorieLogModel(
        userId: userId,
        calories: calories,
        mealType: mealType,
        createdAt: DateTime.now(),
      );

      await _supabase.from('calorie_logs').insert(entry.toJson());
      await fetchAnalyticsData();
    } catch (e) {
      emit(AnalyticsError("Failed to add calories: ${e.toString()}"));
    }
  }
}
