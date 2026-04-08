import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diet_coach/features/patient/saved_meals/models/saved_meal_model.dart';
import 'package:ai_diet_coach/features/patient/saved_meals/view_models/saved_meals_cubit/saved_meals_state.dart';

class SavedMealsCubit extends Cubit<SavedMealsState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  SavedMealsCubit() : super(SavedMealsInitial());

  Future<void> fetchMeals() async {
    emit(SavedMealsLoading());
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        emit(SavedMealsFailure("User not authenticated"));
        return;
      }

      final response = await _supabase
          .from('meals')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<SavedMealModel> meals = (response as List<dynamic>)
          .map((json) => SavedMealModel.fromJson(json))
          .toList();

      emit(SavedMealsLoaded(meals));
    } catch (e) {
      emit(SavedMealsFailure('Failed to load meals: $e'));
    }
  }
}
