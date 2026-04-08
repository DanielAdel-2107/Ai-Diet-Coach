class WeightLogModel {
  final String? id;
  final String userId;
  final double weight;
  final DateTime createdAt;

  WeightLogModel({
    this.id,
    required this.userId,
    required this.weight,
    required this.createdAt,
  });

  factory WeightLogModel.fromJson(Map<String, dynamic> json) {
    return WeightLogModel(
      id: json['id'],
      userId: json['user_id'],
      weight: (json['weight'] as num).toDouble(),
      createdAt: DateTime.parse(json['recorded_at'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'weight': weight,
      'recorded_at': createdAt.toIso8601String(),
    };
  }
}

class CalorieLogModel {
  final String? id;
  final String userId;
  final int calories;
  final String? mealType;
  final String? foodName;
  final DateTime createdAt;

  CalorieLogModel({
    this.id,
    required this.userId,
    required this.calories,
    this.mealType,
    this.foodName,
    required this.createdAt,
  });

  factory CalorieLogModel.fromJson(Map<String, dynamic> json) {
    return CalorieLogModel(
      id: json['id'],
      userId: json['user_id'],
      calories: (json['calories'] as num).toInt(),
      mealType: json['meal_type'],
      foodName: json['food_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'calories': calories,
      'meal_type': mealType,
      'food_name': foodName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SugarLevelModel {
  final String? id;
  final String userId;
  final double level;
  final String mealTag; // 'before_meal', 'after_meal', 'fasting'
  final DateTime createdAt;

  SugarLevelModel({
    this.id,
    required this.userId,
    required this.level,
    required this.mealTag,
    required this.createdAt,
  });

  factory SugarLevelModel.fromJson(Map<String, dynamic> json) {
    return SugarLevelModel(
      id: json['id'],
      userId: json['user_id'],
      level: (json['level'] as num).toDouble(),
      mealTag: json['meal_tag'] ?? 'unspecified',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'level': level,
      'meal_tag': mealTag,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
