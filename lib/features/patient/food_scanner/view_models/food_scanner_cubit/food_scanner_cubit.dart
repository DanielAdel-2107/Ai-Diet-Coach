import 'dart:io';
import 'package:ai_diet_coach/core/helper/pick_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/models/food_analysis_model.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/view_models/food_scanner_cubit/food_scanner_state.dart';
import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diet_coach/core/di/dependancy_injection.dart';

class FoodScannerCubit extends Cubit<FoodScannerState> {
  final GeminiService service;
  File? _pickedImage;

  FoodScannerCubit(this.service) : super(FoodScannerInitial());

  Future<void> pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      _pickedImage = File(image.path);
      emit(FoodScannerImagePicked(_pickedImage!));
      // Start analysis automatically
      await analyzeFood(100.0);
    }
  }

  Future<void> analyzeFood(double grams) async {
    if (_pickedImage == null) {
      emit(FoodScannerFailure("Please select an image first."));
      return;
    }

    emit(FoodScannerAnalyzing(_pickedImage!));
    try {
      final imageBytes = await _pickedImage!.readAsBytes();
      final analysis = await service.analyzeFoodImage(
        imageBytes: imageBytes,
        grams: grams,
      );
      emit(FoodScannerSuccess(analysis));
    } catch (e) {
      emit(FoodScannerFailure('Failed to analyze food: $e'));
    }
  }

  void reset() {
    _pickedImage = null;
    emit(FoodScannerInitial());
  }

  Future<void> saveToLog(FoodAnalysisModel analysis) async {
    final supabase = getIt<SupabaseClient>();
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      emit(FoodScannerFailure('User not authenticated'));
      return;
    }

    emit(FoodScannerSaving(analysis));
    try {
      final now = DateTime.now();
      final mealType = _getMealTypeByTime(now.hour);

      final data = {
        'user_id': userId,
        'meal_type': mealType,
        'food_name': analysis.foodName,
        'grams': analysis.grams,
        'calories': analysis.calories,
        'protein': analysis.protein,
        'carbs': analysis.carbs,
        'fat': analysis.fat,
        'fiber': analysis.fiber,
        'meal_date': now.toIso8601String().split('T')[0], // YYYY-MM-DD
      };

      await supabase.from('meals').insert(data);
      emit(FoodScannerSavedSuccess());
    } catch (e) {
      emit(FoodScannerFailure('Failed to save meal: $e'));
    }
  }

  String _getMealTypeByTime(int hour) {
    if (hour >= 5 && hour < 11) return 'Breakfast';
    if (hour >= 11 && hour < 16) return 'Lunch';
    if (hour >= 18 && hour < 23) return 'Dinner';
    return 'Snack';
  }
}

// Wrapper for the helper since it has a naming conflict with our method
Future<File?> pickImageHelper({required ImageSource source}) => pickImage(source: source);
