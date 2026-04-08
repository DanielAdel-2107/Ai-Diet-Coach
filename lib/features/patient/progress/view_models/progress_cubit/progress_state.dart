import 'package:ai_diet_coach/features/patient/progress/models/progress_models.dart';

abstract class ProgressState {}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressSuccess extends ProgressState {
  final List<WeightLogModel> weightLogs;
  final List<CalorieLogModel> calorieLogs;
  final List<SugarLevelModel> sugarLogs;

  ProgressSuccess({
    required this.weightLogs,
    required this.calorieLogs,
    required this.sugarLogs,
  });

  // Latest values for summary cards
  WeightLogModel? get latestWeight => weightLogs.isNotEmpty ? weightLogs.last : null;
  CalorieLogModel? get latestCalorie => calorieLogs.isNotEmpty ? calorieLogs.last : null;
  SugarLevelModel? get latestSugar => sugarLogs.isNotEmpty ? sugarLogs.last : null;

  double get weightChange {
    if (weightLogs.length < 2) return 0;
    return weightLogs.last.weight - weightLogs.first.weight;
  }
}

class ProgressError extends ProgressState {
  final String message;
  ProgressError(this.message);
}
