import 'package:ai_diet_coach/features/patient/analytics/view_models/analytics_cubit/analytics_cubit.dart';
import 'package:ai_diet_coach/features/patient/analytics/views/widgets/analytics_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsCubit(GetIt.I<SupabaseClient>())..fetchAnalyticsData(),
      child: const Scaffold(
        body: AnalyticsBody(),
      ),
    );
  }
}
