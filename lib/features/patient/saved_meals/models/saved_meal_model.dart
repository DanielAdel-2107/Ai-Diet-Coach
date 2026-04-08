class SavedMealModel {
  final String id;
  final String mealType;
  final String foodName;
  final double grams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealDate;

  SavedMealModel({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealDate,
  });

  factory SavedMealModel.fromJson(Map<String, dynamic> json) {
    return SavedMealModel(
      id: json['id']?.toString() ?? '',
      mealType: json['meal_type'] ?? 'Snack',
      foodName: json['food_name'] ?? 'Unknown',
      grams: (json['grams'] as num?)?.toDouble() ?? 0.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      mealDate: json['meal_date'] ?? '',
    );
  }
}
