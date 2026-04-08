import 'package:ai_diet_coach/features/patient/saved_meals/models/saved_meal_model.dart';

abstract class SavedMealsState {}

class SavedMealsInitial extends SavedMealsState {}

class SavedMealsLoading extends SavedMealsState {}

class SavedMealsLoaded extends SavedMealsState {
  final List<SavedMealModel> meals;
  SavedMealsLoaded(this.meals);
}

class SavedMealsFailure extends SavedMealsState {
  final String error;
  SavedMealsFailure(this.error);
}
