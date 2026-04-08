import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class SugarState {}

class SugarInitial extends SugarState {}

class SugarLoading extends SugarState {}

class SugarSuccess extends SugarState {
  final List<SugarLevelModel> levels;
  final double average;
  SugarSuccess(this.levels, this.average);
}

class SugarFailure extends SugarState {
  final String error;
  SugarFailure(this.error);
}

class SugarAddedSuccess extends SugarState {}

class SugarAdding extends SugarState {}
