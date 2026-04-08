import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/saved_meals/models/saved_meal_model.dart';
import 'package:ai_diet_coach/features/patient/saved_meals/view_models/saved_meals_cubit/saved_meals_cubit.dart';
import 'package:ai_diet_coach/features/patient/saved_meals/view_models/saved_meals_cubit/saved_meals_state.dart';

class SavedMealsBody extends StatelessWidget {
  const SavedMealsBody({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<SavedMealsCubit, SavedMealsState>(
              builder: (context, state) {
                if (state is SavedMealsLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } else if (state is SavedMealsFailure) {
                  return Center(
                    child: Text(state.error, style: AppTextStyles.title16GreyW500),
                  );
                } else if (state is SavedMealsLoaded) {
                  if (state.meals.isEmpty) {
                    return Center(
                      child: Text("No meals saved yet.", style: AppTextStyles.title16GreyW500),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => context.read<SavedMealsCubit>().fetchMeals(),
                    color: AppColors.primary,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05, vertical: SizeConfig.height * 0.02),
                      itemCount: state.meals.length,
                      itemBuilder: (context, index) {
                        return _buildMealCard(state.meals[index], index);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.width * 0.05,
        vertical: SizeConfig.height * 0.02,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              padding: const EdgeInsets.all(12),
            ),
          ),
          SizedBox(width: SizeConfig.width * 0.04),
          Text(
            "Saved Meals",
            style: AppTextStyles.title26BlackBold.copyWith(letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(SavedMealModel meal, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * (index > 5 ? 5 : index)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meal.mealType,
                    style: AppTextStyles.title12PrimaryColorW500.copyWith(color: AppColors.secondary),
                  ),
                ),
                Text(
                  meal.mealDate,
                  style: AppTextStyles.title12Grey,
                ),
              ],
            ),
            SizedBox(height: SizeConfig.height * 0.02),
            Text(
              meal.foodName,
              style: AppTextStyles.title20BlackBold,
            ),
            SizedBox(height: SizeConfig.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMacroItem("Calories", "${meal.calories.toInt()} kcal", AppColors.primary),
                _buildMacroItem("Protein", "${meal.protein.toInt()}g", AppColors.secondary),
                _buildMacroItem("Carbs", "${meal.carbs.toInt()}g", AppColors.chartOrange),
                _buildMacroItem("Fat", "${meal.fat.toInt()}g", AppColors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.title16BlackBold.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.title12Grey.copyWith(fontSize: 10)),
      ],
    );
  }
}
