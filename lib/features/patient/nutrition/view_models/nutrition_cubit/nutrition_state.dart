import 'package:ai_diet_coach/features/patient/nutrition/models/nutrition_plan_model.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class NutritionState {}

class NutritionInitial extends NutritionState {}

class NutritionGenerating extends NutritionState {}

class NutritionSuccess extends NutritionState {
  final NutritionPlanModel plan;
  NutritionSuccess(this.plan);
}

class NutritionFailure extends NutritionState {
  final String error;
  NutritionFailure(this.error);
}

class NutritionSaving extends NutritionState {}

class NutritionSaveSuccess extends NutritionState {}
