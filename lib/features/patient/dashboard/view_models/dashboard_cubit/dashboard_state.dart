import 'package:ai_diet_coach/features/patient/dashboard/models/patient_progress_model.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardSuccess extends DashboardState {
  final PatientProgressModel data;
  DashboardSuccess(this.data);
}

class DashboardFailure extends DashboardState {
  final String error;
  DashboardFailure(this.error);
}
