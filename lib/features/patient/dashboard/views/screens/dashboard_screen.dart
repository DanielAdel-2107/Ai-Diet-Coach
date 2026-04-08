import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/dashboard/view_models/dashboard_cubit/dashboard_cubit.dart';
import 'package:ai_diet_coach/features/patient/dashboard/views/widgets/dashboard_screen_body.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit()..fetchDashboardData(),
      child: const Scaffold(
        body: PatientDashboardScreenBody(),
      ),
    );
  }
}
