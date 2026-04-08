import 'dart:io';
import 'package:ai_diet_coach/features/patient/food_scanner/models/food_analysis_model.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class FoodScannerState {}

class FoodScannerInitial extends FoodScannerState {}

class FoodScannerImagePicked extends FoodScannerState {
  final File image;
  FoodScannerImagePicked(this.image);
}

class FoodScannerAnalyzing extends FoodScannerState {
  final File image;
  FoodScannerAnalyzing(this.image);
}

class FoodScannerSuccess extends FoodScannerState {
  final FoodAnalysisModel analysis;
  FoodScannerSuccess(this.analysis);
}

class FoodScannerFailure extends FoodScannerState {
  final String error;
  FoodScannerFailure(this.error);
}

class FoodScannerSaving extends FoodScannerState {
  final FoodAnalysisModel analysis;
  FoodScannerSaving(this.analysis);
}

class FoodScannerSavedSuccess extends FoodScannerState {}
