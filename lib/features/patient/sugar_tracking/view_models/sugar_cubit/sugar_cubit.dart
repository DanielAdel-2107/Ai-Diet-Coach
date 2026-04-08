import 'package:ai_diet_coach/core/network/supabase/database/add_data.dart';
import 'package:ai_diet_coach/core/network/supabase/database/get_data.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/view_models/sugar_cubit/sugar_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diet_coach/core/di/dependancy_injection.dart';

class SugarCubit extends Cubit<SugarState> {
  SugarCubit() : super(SugarInitial());

  Future<void> loadSugarLevels() async {
    emit(SugarLoading());
    try {
      final response = await getData(tableName: 'sugar_levels', orderBy: 'created_at');
      final levels = response.map((json) => SugarLevelModel.fromJson(json)).toList();
      
      // Ensure chronological order for charts
      levels.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      double average = 0;
      if (levels.isNotEmpty) {
        average = levels.map((e) => e.level).reduce((a, b) => a + b) / levels.length;
      }
      
      emit(SugarSuccess(levels, average));
    } catch (e) {
      emit(SugarFailure('Failed to load sugar levels: $e'));
    }
  }

  Future<void> addSugarLevel(double level, String type) async {
    final supabase = getIt<SupabaseClient>();
    final userId = supabase.auth.currentUser?.id;
    
    if (userId == null) {
      emit(SugarFailure('User not authenticated'));
      return;
    }

    emit(SugarAdding());
    try {
      final data = {
        'user_id': userId,
        'level': level,
        'meal_tag': type,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await addData(tableName: 'sugar_levels', data: data);
      emit(SugarAddedSuccess());
      // We don't call loadSugarLevels here if it emits SugarLoading 
      // because we already have SugarAddedSuccess which handles the transition.
      // But we need to refresh the list, so we'll do it manually.
      await _refreshAfterAdd(); 
    } catch (e) {
      emit(SugarFailure('Failed to add sugar level: $e'));
    }
  }

  Future<void> _refreshAfterAdd() async {
    try {
      final response = await getData(tableName: 'sugar_levels', orderBy: 'created_at');
      final levels = response.map((json) => SugarLevelModel.fromJson(json)).toList();
      levels.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      double average = 0;
      if (levels.isNotEmpty) {
        average = levels.map((e) => e.level).reduce((a, b) => a + b) / levels.length;
      }
      emit(SugarSuccess(levels, average));
    } catch (e) {
      emit(SugarFailure('Reload failed: $e'));
    }
  }
}
