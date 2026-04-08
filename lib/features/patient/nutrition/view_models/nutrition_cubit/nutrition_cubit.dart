import 'package:ai_diet_coach/core/di/dependancy_injection.dart';
import 'package:ai_diet_coach/core/network/supabase/database/add_data.dart';
import 'package:ai_diet_coach/core/network/supabase/database/get_data_with_spacific_id.dart';
import 'package:ai_diet_coach/features/auth/sign_up/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/nutrition/models/nutrition_plan_model.dart';
import 'package:ai_diet_coach/features/patient/nutrition/view_models/nutrition_cubit/nutrition_state.dart';
import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionCubit extends Cubit<NutritionState> {
  final GeminiService service;

  NutritionCubit(this.service) : super(NutritionInitial());

  Future<void> generatePlan() async {
    emit(NutritionGenerating());
    try {
      final user = getIt<SupabaseClient>().auth.currentUser;
      if (user == null) {
        emit(NutritionFailure("User not authenticated"));
        return;
      }

      // Fetch user profile from Supabase
      final profileData = await getDataWithSpacificId(
        tableName: 'user_profiles',
        id: user.id,
      );

      if (profileData.isEmpty) {
        emit(NutritionFailure("Please complete your profile first."));
        return;
      }

      final userModel = UserModel.fromJson(profileData.first);

      // Call Gemini API with real user data
      final plan = await service.generateDietPlan(
        age: userModel.age ?? 25,
        weight: userModel.weight ?? 70.0,
        height: userModel.height ?? 170.0,
        goal: userModel.goal ?? "Maintain weight",
      );

      emit(NutritionSuccess(plan));
    } catch (e) {
      emit(NutritionFailure(e.toString()));
    }
  }

  Future<void> savePlan(NutritionPlanModel plan) async {
    final user = getIt<SupabaseClient>().auth.currentUser;
    if (user == null) return;

    emit(NutritionSaving());

    try {
      for (var meal in plan.meals) {
        await addData(
          tableName: 'nutrition_plans',
          data: {
            'user_id': user.id,
            'meal_type': meal.type,
            'meal_name': meal.name,
            'calories': meal.calories,
            'protein': meal.macros.protein,
            'carbs': meal.macros.carbs,
            'fat': meal.macros.fats,
          },
        );
      }
      emit(NutritionSaveSuccess());
      // Re-emit success with the plan to keep the UI showing the plan
      emit(NutritionSuccess(plan));
    } catch (e) {
      emit(NutritionFailure("Failed to save plan: $e"));
      emit(NutritionSuccess(plan));
    }
  }
}
