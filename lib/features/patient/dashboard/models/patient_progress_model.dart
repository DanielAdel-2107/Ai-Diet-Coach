class PatientProgressModel {
  final String userName;
  final double caloriesToday;
  final double caloriesGoal;
  final String workoutPlan;
  final String nutritionPlan;
  final double sugarLevel;
  final String sugarStatus;

  PatientProgressModel({
    required this.userName,
    required this.caloriesToday,
    required this.caloriesGoal,
    required this.workoutPlan,
    required this.nutritionPlan,
    required this.sugarLevel,
    required this.sugarStatus,
  });

  static String getSugarLevelStatus(double level) {
    if (level <= 0) return "No Data";
    if (level < 100) return "Optimal";
    if (level <= 125) return "Pre-diabetic";
    return "High";
  }

  double get caloriePercentage {
    if (caloriesGoal <= 0) return 0.0;
    return (caloriesToday / caloriesGoal).clamp(0.0, 1.0);
  }
}
