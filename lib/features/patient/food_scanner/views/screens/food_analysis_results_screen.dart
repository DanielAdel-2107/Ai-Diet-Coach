import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/models/food_analysis_model.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/view_models/food_scanner_cubit/food_scanner_cubit.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/views/widgets/results_screen_body.dart';

class FoodAnalysisResultsScreen extends StatelessWidget {
  final FoodAnalysisModel analysis;
  final FoodScannerCubit cubit;

  const FoodAnalysisResultsScreen({
    super.key,
    required this.analysis,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        body: FoodAnalysisResultsBody(analysis: analysis),
      ),
    );
  }
}
