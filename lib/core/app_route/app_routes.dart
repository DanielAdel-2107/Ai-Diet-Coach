import 'package:ai_diet_coach/core/app_route/route_names.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/views/screens/food_scanner_screen.dart';
import 'package:ai_diet_coach/features/patient/nutrition/views/screens/nutrition_screen.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/views/screens/workout_plan_screen.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/views/screens/sugar_tracking_screen.dart';
import 'package:ai_diet_coach/features/patient/reminders/views/screens/reminders_screen.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/views/screens/ai_chat_screen.dart';
import 'package:ai_diet_coach/features/patient/progress/views/screens/progress_screen.dart';
import 'package:ai_diet_coach/features/patient/sugar_device/views/screens/sugar_device_screen.dart';
import 'package:ai_diet_coach/features/splash/views/screens/splash_screen.dart';
import 'package:ai_diet_coach/features/on_boarding/views/screens/on_boarding_screen.dart';
import 'package:ai_diet_coach/features/auth/sign_in/views/screens/sign_in_screen.dart';
import 'package:ai_diet_coach/features/auth/sign_up/views/screens/sign_up_screen.dart';
import 'package:ai_diet_coach/features/patient/dashboard/views/screens/dashboard_screen.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/views/screens/food_analysis_results_screen.dart';
import 'package:ai_diet_coach/features/patient/workout/views/screens/workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:ai_diet_coach/features/patient/saved_meals/views/screens/saved_meals_screen.dart';

class AppRoutes {
  static Map<String, Widget Function(BuildContext)> routes =
      <String, WidgetBuilder>{
    RouteNames.savedMealsScreen: (context) => const SavedMealsScreen(),
    RouteNames.nutritionScreen: (context) => const PatientNutritionScreen(),
    RouteNames.foodScannerScreen: (context) => const FoodScannerScreen(),
    RouteNames.workoutScreen: (context) => const WorkoutScreen(),
    RouteNames.workoutPlanScreen: (context) => const WorkoutPlanScreen(),
    RouteNames.sugarTrackingScreen: (context) => const SugarTrackingScreen(),
    RouteNames.remindersScreen: (context) => const RemindersScreen(),
    RouteNames.aiChatScreen: (context) => const AIChatScreen(),
    RouteNames.progressScreen: (context) => const ProgressScreen(),
    RouteNames.sugarDeviceScreen: (context) => const SugarDeviceScreen(),
    RouteNames.splashScreen: (context) => const SplashScreen(),
    RouteNames.onBoardingScreen: (context) => const OnBoardingScreen(),
    RouteNames.signInScreen: (context) => const SignInScreen(),
    RouteNames.signUpScreen: (context) => const SignUpScreen(),
    RouteNames.dashboardScreen: (context) => const PatientDashboardScreen(),
    RouteNames.foodAnalysisResultsScreen: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['analysis'] == null || args['cubit'] == null) {
        return const Scaffold(
          body: Center(child: Text("Error: Navigation data missing.")),
        );
      }
      return FoodAnalysisResultsScreen(
        analysis: args['analysis'],
        cubit: args['cubit'],
      );
    },
  };
}
