import 'package:ai_diet_coach/core/di/dependancy_injection.dart';
import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/view_models/workout_plan_cubit/workout_plan_cubit.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/views/widgets/workout_plan_body.dart';

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => 
          WorkoutPlanCubit(getIt<GeminiService>())..loadSavedPlan(),
      child: const Scaffold(
        body: WorkoutPlanBody(),
      ),
    );
  }
}
