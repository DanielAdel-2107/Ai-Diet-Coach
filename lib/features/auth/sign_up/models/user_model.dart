class UserModel {
  final String id;
  final String name;
  final String email;
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;
  final String? goal;
  final String? activityLevel;
  final double? bmi;

  final List<String>? likedFoods;
  final List<String>? dislikedFoods;
  final List<String>? allergies;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.goal,
    this.activityLevel,
    this.bmi,
    this.likedFoods,
    this.dislikedFoods,
    this.allergies,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'goal': goal,
      'activity_level': activityLevel,
      'bmi': bmi,
      'liked_foods': likedFoods,
      'disliked_foods': dislikedFoods,
      'allergies': allergies,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'],
      age: json['age'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      goal: json['goal'],
      activityLevel: json['activity_level'],
      bmi: json['bmi']?.toDouble(),
      likedFoods: (json['liked_foods'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      dislikedFoods: (json['disliked_foods'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      allergies: (json['allergies'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
