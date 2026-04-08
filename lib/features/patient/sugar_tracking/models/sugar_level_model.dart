
class SugarLevelModel {
  final String id;
  final String userId;
  final double level;
  final String mealTag; // 'before_meal' or 'after_meal'
  final DateTime createdAt;

  SugarLevelModel({
    required this.id,
    required this.userId,
    required this.level,
    required this.mealTag,
    required this.createdAt,
  });

  factory SugarLevelModel.fromJson(Map<String, dynamic> json) {
    return SugarLevelModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      level: (json['level'] as num).toDouble(),
      mealTag: json['meal_tag'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
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
