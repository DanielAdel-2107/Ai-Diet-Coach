class NutritionPlanModel {
  final List<MealDetail> meals;
  final Macros totalMacros;
  final String objective;

  NutritionPlanModel({
    required this.meals,
    required this.totalMacros,
    required this.objective,
  });

  factory NutritionPlanModel.fromJson(Map<String, dynamic> json) {
    return NutritionPlanModel(
      meals: (json['meals'] as List)
          .map((m) => MealDetail.fromJson(m))
          .toList(),
      totalMacros: Macros.fromJson(json['total_macros']),
      objective: json['objective'] ?? "",
    );
  }
}

class MealDetail {
  final String type; // Breakfast, Lunch, Dinner, Snack
  final String name;
  final List<String> ingredients;
  final double calories;
  final Macros macros;

  MealDetail({
    required this.type,
    required this.name,
    required this.ingredients,
    required this.calories,
    required this.macros,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    return MealDetail(
      type: json['type'],
      name: json['name'],
      ingredients: List<String>.from(json['ingredients']),
      calories: json['calories'].toDouble(),
      macros: Macros.fromJson(json['macros']),
    );
  }
}

class Macros {
  final double protein;
  final double carbs;
  final double fats;

  Macros({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory Macros.fromJson(Map<String, dynamic> json) {
    return Macros(
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fats: json['fats'].toDouble(),
    );
  }
}
