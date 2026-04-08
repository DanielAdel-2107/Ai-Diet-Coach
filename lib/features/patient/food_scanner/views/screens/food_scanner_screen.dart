import 'package:ai_diet_coach/core/di/dependancy_injection.dart';
import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/view_models/food_scanner_cubit/food_scanner_cubit.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/views/widgets/scanner_body.dart';

class FoodScannerScreen extends StatelessWidget {
  const FoodScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FoodScannerCubit(getIt<GeminiService>()),
      child: const Scaffold(
        body: SafeArea(
          child: FoodScannerScreenBody(),
        ),
      ),
    );
  }
}
