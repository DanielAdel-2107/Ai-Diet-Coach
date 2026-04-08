import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/saved_meals/view_models/saved_meals_cubit/saved_meals_cubit.dart';
import 'package:ai_diet_coach/features/patient/saved_meals/views/widgets/saved_meals_body.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';

class SavedMealsScreen extends StatelessWidget {
  const SavedMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SavedMealsCubit()..fetchMeals(),
      child: const Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SavedMealsBody(),
      ),
    );
  }
}
