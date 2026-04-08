class FoodAnalysisModel {
  final String foodName;
  final double grams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  FoodAnalysisModel({
    required this.foodName,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory FoodAnalysisModel.fromJson(Map<String, dynamic> json, double grams) {
    return FoodAnalysisModel(
      foodName: json['food_name'] ?? "Unknown Food",
      grams: grams,
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
    );
  }
}
