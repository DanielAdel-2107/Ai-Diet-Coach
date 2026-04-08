import 'package:ai_diet_coach/features/patient/progress/view_models/progress_cubit/progress_cubit.dart';
import 'package:ai_diet_coach/features/patient/progress/views/widgets/progress_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgressCubit(GetIt.I<SupabaseClient>())..fetchProgressData(),
      child: const Scaffold(
        body: ProgressBody(),
      ),
    );
  }
}
