import 'package:ai_diet_coach/core/di/dependancy_injection.dart';
import 'package:ai_diet_coach/core/network/supabase/database/add_data.dart';
import 'package:ai_diet_coach/core/network/supabase/database/get_data_with_spacific_id.dart';
import 'package:ai_diet_coach/core/network/supabase/database/remove_data.dart';
import 'package:ai_diet_coach/features/auth/sign_up/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/nutrition/models/nutrition_plan_model.dart';
import 'package:ai_diet_coach/features/patient/nutrition/view_models/nutrition_cubit/nutrition_state.dart';
import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionCubit extends Cubit<NutritionState> {
  final GeminiService service;

  NutritionCubit(this.service) : super(NutritionInitial());

  Future<void> fetchPlan() async {
    final user = getIt<SupabaseClient>().auth.currentUser;
    if (user == null) {
      emit(NutritionFailure("User not authenticated"));
      return;
    }

    emit(NutritionGenerating());
    try {
      final planData = await getIt<SupabaseClient>()
          .from('nutrition_plans')
          .select()
          .eq('user_id', user.id);

      if (planData.isNotEmpty) {
        List<MealDetail> meals = planData.map((m) {
          return MealDetail(
            type: m['meal_type'] ?? "Meal",
            name: m['meal_name'] ?? "Unknown",
            ingredients: [],
            calories: (m['calories'] as num?)?.toDouble() ?? 0.0,
            macros: Macros(
              protein: (m['protein'] as num?)?.toDouble() ?? 0.0,
              carbs: (m['carbs'] as num?)?.toDouble() ?? 0.0,
              fats: (m['fat'] as num?)?.toDouble() ?? 0.0,
            ),
          );
        }).toList();

        final plan = NutritionPlanModel(
          meals: meals,
          totalMacros: Macros(
            protein: meals.fold(0.0, (sum, item) => sum + item.macros.protein),
            carbs: meals.fold(0.0, (sum, item) => sum + item.macros.carbs),
            fats: meals.fold(0.0, (sum, item) => sum + item.macros.fats),
          ),
          objective: "Your Saved Diet Plan",
        );
        emit(NutritionSuccess(plan));
      } else {
        emit(NutritionInitial());
      }
    } catch (e) {
      emit(NutritionFailure("Failed to fetch plan: $e"));
    }
  }

  Future<void> generatePlan({
    List<String>? likedFoods,
    List<String>? dislikedFoods,
    List<String>? allergies,
    String? additionalNotes,
  }) async {
    emit(NutritionGenerating());
    try {
      final user = getIt<SupabaseClient>().auth.currentUser;
      if (user == null) {
        emit(NutritionFailure("User not authenticated"));
        return;
      }

      final profileData = await getDataWithSpacificId(
        tableName: 'user_profiles',
        id: user.id,
      );

      if (profileData.isEmpty) {
        emit(NutritionFailure("Please complete your profile first."));
        return;
      }

      final userModel = UserModel.fromJson(profileData.first);

      final plan = await service.generateDietPlan(
        age: userModel.age ?? 25,
        weight: userModel.weight ?? 70.0,
        height: userModel.height ?? 170.0,
        goal: userModel.goal ?? "Maintain weight",
        likedFoods: likedFoods ?? userModel.likedFoods,
        dislikedFoods: dislikedFoods ?? userModel.dislikedFoods,
        allergies: allergies ?? userModel.allergies,
        additionalNotes: additionalNotes,
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
      // 1. Remove old plan
      await getIt<SupabaseClient>()
          .from('nutrition_plans')
          .delete()
          .eq('user_id', user.id);

      // 2. Prepare batch data
      final List<Map<String, dynamic>> mealsData = plan.meals
          .map(
            (meal) => {
              'user_id': user.id,
              'meal_type': meal.type,
              'meal_name': meal.name,
              'calories': meal.calories,
              'protein': meal.macros.protein,
              'carbs': meal.macros.carbs,
              'fat': meal.macros.fats,
            },
          )
          .toList();

      // 3. Direct Insert
      await getIt<SupabaseClient>().from('nutrition_plans').insert(mealsData);

      emit(NutritionSaveSuccess());
      emit(NutritionSuccess(plan));
    } catch (e) {
      emit(NutritionFailure("Save Error: $e"));
      emit(NutritionSuccess(plan));
    }
  }

  Future<void> savePreferences({
    required List<String> likedFoods,
    required List<String> dislikedFoods,
    required List<String> allergies,
  }) async {
    final user = getIt<SupabaseClient>().auth.currentUser;
    if (user == null) return;

    try {
      await addData(
        tableName: 'user_profiles',
        data: {
          'id': user.id,
          'liked_foods': likedFoods,
          'disliked_foods': dislikedFoods,
          'allergies': allergies,
        },
      );
    } catch (e) {
      print("Error saving preferences: $e");
    }
  }
}
