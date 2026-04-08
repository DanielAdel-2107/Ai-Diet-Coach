import 'package:ai_diet_coach/features/patient/workout/models/exercise_model.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class WorkoutState {}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final List<ExerciseModel> exercises;
  final String activeCategory;
  final List<String> categories;
  
  WorkoutLoaded(this.exercises, this.activeCategory, this.categories);
}

class WorkoutFailure extends WorkoutState {
  final String error;
  WorkoutFailure(this.error);
}
