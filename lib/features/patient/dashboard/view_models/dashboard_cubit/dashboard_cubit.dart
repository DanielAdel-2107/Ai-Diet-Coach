import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diet_coach/features/patient/dashboard/models/patient_progress_model.dart';
import 'package:ai_diet_coach/features/patient/dashboard/view_models/dashboard_cubit/dashboard_state.dart';
import 'package:intl/intl.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  DashboardCubit() : super(DashboardInitial());

  Future<void> fetchDashboardData() async {
    emit(DashboardLoading());
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        emit(DashboardFailure("User session lost. Please re-login."));
        return;
      }

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dayOfWeek = DateFormat('EEEE').format(DateTime.now());

      // Concurrent fetching for performance. Use maybeSingle() to prevent "No row found" or "Multiple rows found" errors.
      final results = await Future.wait<dynamic>([
        _supabase
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle(),
        _supabase
            .from('meals')
            .select('calories')
            .eq('user_id', user.id)
            .eq('meal_date', today),
        _supabase
            .from('workout_plans')
            .select('focus, is_rest_day')
            .eq('user_id', user.id)
            .eq('day_of_week', dayOfWeek)
            .limit(1)
            .maybeSingle(),
        _supabase
            .from('nutrition_plans')
            .select('meal_name')
            .eq('user_id', user.id)
            .eq('day_of_week', dayOfWeek)
            .limit(1)
            .maybeSingle(),
        _supabase
            .from('sugar_levels')
            .select('level')
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle(),
      ]);

      final profile = results[0] as Map<String, dynamic>?;
      final mealsData = results[1] as List<dynamic>;
      final workoutData = results[2] as Map<String, dynamic>?;
      final nutritionData = results[3] as Map<String, dynamic>?;
      final sugarData = results[4] as Map<String, dynamic>?;

      // 1. Calculate Calories Today (Safely handle nulls)
      double caloriesToday = 0;
      if (mealsData.isNotEmpty) {
        for (var meal in mealsData) {
          caloriesToday += (meal['calories'] as num? ?? 0).toDouble();
        }
      }

      // 2. Calorie Goal (Fetch from profile, fallback to 2000)
      double caloriesGoal = (profile?['calorie_goal'] as num?)?.toDouble() ?? 2000;

      // 3. Workout Focus (Handle nulls)
      String workoutPlan = "Rest Day";
      if (workoutData != null) {
        if (workoutData['is_rest_day'] == true) {
          workoutPlan = "Rest & Recover";
        } else {
          workoutPlan = (workoutData['focus'] as String?) ?? "Training Session";
        }
      }

      // 4. Nutrition Recommendation
      String nutritionPlan =
          (nutritionData?['meal_name'] as String?) ?? "Check your plan";

      // 5. Sugar Level
      double sugarLevel = (sugarData?['level'] as num?)?.toDouble() ?? 0.0;

      final dashboardData = PatientProgressModel(
        userName: (profile?['name'] as String?) ?? "User",
        caloriesToday: caloriesToday,
        caloriesGoal: caloriesGoal,
        workoutPlan: workoutPlan,
        nutritionPlan: nutritionPlan,
        sugarLevel: sugarLevel,
        sugarStatus: PatientProgressModel.getSugarLevelStatus(sugarLevel),
      );

      emit(DashboardSuccess(dashboardData));
    } catch (e) {
      // In production, keep generic message. For debugging, log the error.
      print("Dashboard Error: $e");
      emit(DashboardFailure("Failed to sync dashboard. Swipe down to retry."));
    }
  }

  void refresh() => fetchDashboardData();
}
