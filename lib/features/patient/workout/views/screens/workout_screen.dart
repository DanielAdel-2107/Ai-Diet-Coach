import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/workout/view_models/workout_cubit/workout_cubit.dart';
import 'package:ai_diet_coach/features/patient/workout/views/widgets/workout_body.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkoutCubit()..loadWorkouts(),
      child: const Scaffold(
        body: WorkoutScreenBody(),
      ),
    );
  }
}
