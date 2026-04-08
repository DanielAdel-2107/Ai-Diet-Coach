import 'package:ai_diet_coach/features/patient/workout_plan/models/workout_plan_model.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class WorkoutPlanState {}

class WorkoutPlanInitial extends WorkoutPlanState {}

class WorkoutPlanLoading extends WorkoutPlanState {}

class WorkoutPlanLoaded extends WorkoutPlanState {
  final WorkoutPlanModel plan;
  final int selectedDayIndex;
  WorkoutPlanLoaded(this.plan, {this.selectedDayIndex = 0});
}

class WorkoutPlanFailure extends WorkoutPlanState {
  final String error;
  WorkoutPlanFailure(this.error);
}
