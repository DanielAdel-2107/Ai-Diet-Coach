import 'package:ai_diet_coach/features/patient/analytics/models/analytics_models.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';

abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsSuccess extends AnalyticsState {
  final List<WeightLogModel> weightLogs;
  final List<CalorieLogModel> calorieLogs;
  final List<SugarLevelModel> sugarLogs;

  AnalyticsSuccess({
    required this.weightLogs,
    required this.calorieLogs,
    required this.sugarLogs,
  });
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}
