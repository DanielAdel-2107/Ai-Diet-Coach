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
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['recorded_at'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'weight': weight,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CalorieLogModel {
  final String? id;
  final String userId;
  final int calories;
  final String? mealType;
  final DateTime createdAt;

  CalorieLogModel({
    this.id,
    required this.userId,
    required this.calories,
    this.mealType,
    required this.createdAt,
  });

  factory CalorieLogModel.fromJson(Map<String, dynamic> json) {
    return CalorieLogModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      mealType: json['meal_type']?.toString(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'calories': calories,
      'meal_type': mealType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
