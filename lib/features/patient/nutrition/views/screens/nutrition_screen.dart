import 'package:ai_diet_coach/core/di/dependancy_injection.dart';
import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/nutrition/view_models/nutrition_cubit/nutrition_cubit.dart';
import 'package:ai_diet_coach/features/patient/nutrition/views/widgets/nutrition_screen_body.dart';

class PatientNutritionScreen extends StatelessWidget {
  const PatientNutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NutritionCubit(getIt<GeminiService>())..generatePlan(),
      child: const Scaffold(body: PatientNutritionScreenBody()),
    );
  }
}
