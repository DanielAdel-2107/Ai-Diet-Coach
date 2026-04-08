class WorkoutPlanModel {
  final String objective;
  final List<DayWorkoutPlan> days;

  WorkoutPlanModel({
    required this.objective,
    required this.days,
  });

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanModel(
      objective: json['objective'] as String,
      days: (json['days'] as List)
          .map((day) => DayWorkoutPlan.fromJson(day))
          .toList(),
    );
  }

  // To build model from Supabase rows
  factory WorkoutPlanModel.fromSupabase(List<dynamic> rows) {
    if (rows.isEmpty) return WorkoutPlanModel(objective: "", days: []);
    
    // Group rows by day_of_week
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var row in rows) {
      final day = row['day_of_week'] as String;
      grouped.putIfAbsent(day, () => []).add(row);
    }

    final List<DayWorkoutPlan> days = grouped.entries.map((entry) {
      final firstRow = entry.value.first;
      return DayWorkoutPlan(
        day: entry.key,
        focus: firstRow['focus'] ?? "",
        isRestDay: firstRow['is_rest_day'] ?? false,
        exercises: entry.value
            .where((r) => r['exercise_name'] != null)
            .map((r) => ExercisePlan(
                  name: r['exercise_name'],
                  sets: r['sets']?.toString() ?? "0",
                  reps: r['reps']?.toString() ?? "0",
                  muscle: r['muscle'] ?? "",
                  intensity: r['intensity'] ?? "",
                ))
            .toList(),
      );
    }).toList();

    return WorkoutPlanModel(objective: "Your Saved Plan", days: days);
  }
}

class DayWorkoutPlan {
  final String day;
  final String focus;
  final List<ExercisePlan> exercises;
  final bool isRestDay;

  DayWorkoutPlan({
    required this.day,
    required this.focus,
    required this.exercises,
    this.isRestDay = false,
  });

  factory DayWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return DayWorkoutPlan(
      day: json['day'] as String,
      focus: json['focus'] as String,
      isRestDay: json['is_rest_day'] ?? false,
      exercises: (json['exercises'] as List?)
              ?.map((ex) => ExercisePlan.fromJson(ex))
              .toList() ??
          [],
    );
  }
}

class ExercisePlan {
  final String name;
  final String sets;
  final String reps;
  final String muscle;
  final String intensity;

  ExercisePlan({
    required this.name,
    required this.sets,
    required this.reps,
    required this.muscle,
    required this.intensity,
  });

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    return ExercisePlan(
      name: json['name'] as String,
      sets: json['sets'].toString(),
      reps: json['reps'].toString(),
      muscle: json['muscle'] as String,
      intensity: json['intensity'] as String,
    );
  }

  Map<String, dynamic> toSupabase(String userId, String day, String focus, bool isRest) {
    return {
      'user_id': userId,
      'day_of_week': day,
      'focus': focus,
      'is_rest_day': isRest,
      'exercise_name': name,
      'sets': int.tryParse(sets) ?? 0,
      'reps': int.tryParse(reps) ?? 0,
      'muscle': muscle,
      'intensity': intensity,
    };
  }
}
