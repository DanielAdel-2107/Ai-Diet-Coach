import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/nutrition/view_models/nutrition_cubit/nutrition_cubit.dart';
import 'package:ai_diet_coach/features/patient/nutrition/view_models/nutrition_cubit/nutrition_state.dart';
import 'package:ai_diet_coach/features/patient/nutrition/views/widgets/macros_summary_card.dart';
import 'package:ai_diet_coach/features/patient/nutrition/views/widgets/meal_section_card.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';

class PatientNutritionScreenBody extends StatelessWidget {
  const PatientNutritionScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NutritionCubit, NutritionState>(
      listener: (context, state) {
        if (state is NutritionSaving) {
          CustomQuickAlert.loading();
        } else if (state is NutritionSaveSuccess) {
          Navigator.pop(context); // Close loading
          CustomQuickAlert.success(
            title: 'Saved!',
            message: 'Your diet plan has been saved successfully.',
          );
        } else if (state is NutritionFailure) {
          // If it was a saving failure, we might need to pop the loading dialog first
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          CustomQuickAlert.error(
            title: 'Error',
            message: state.error,
          );
        }
      },
      child: BlocBuilder<NutritionCubit, NutritionState>(
        builder: (context, state) {
          if (state is NutritionGenerating) {
            return _buildLoadingState();
          } else if (state is NutritionSuccess) {
            final plan = state.plan;
            return Stack(
              children: [
                _buildBackground(),
                SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.width * 0.05,
                                vertical: SizeConfig.height * 0.02,
                              ),
                              child: _buildHeader(context),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.width * 0.05,
                              ),
                              child: MacrosSummaryCard(
                                totalMacros: plan.totalMacros,
                                objective: plan.objective,
                              ),
                            ),
                            SizedBox(height: SizeConfig.height * 0.04),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.width * 0.05,
                              ),
                              child: _buildSectionTitle(),
                            ),
                            SizedBox(height: SizeConfig.height * 0.02),
                            _buildMealsList(plan),
                            SizedBox(height: SizeConfig.height * 0.02),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.width * 0.05,
                              ),
                              child: _buildSaveButton(context, state),
                            ),
                            SizedBox(height: SizeConfig.height * 0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is NutritionFailure) {
            return _buildErrorState(context, state.error);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: SizeConfig.height * 0.03),
          Text(
            "AI is analyzing your profile...",
            style: AppTextStyles.title16GreyW500,
          ),
          SizedBox(height: SizeConfig.height * 0.01),
          const Text("This may take a moment"),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
            SizedBox(height: SizeConfig.height * 0.02),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.title16BlackW500,
            ),
            SizedBox(height: SizeConfig.height * 0.03),
            ElevatedButton(
              onPressed: () => context.read<NutritionCubit>().generatePlan(),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: SizeConfig.height * 0.35,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeInDown(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              padding: const EdgeInsets.all(12),
            ),
          ),
          Text(
            "AI Diet Plan",
            style: AppTextStyles.title24WhiteBold,
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        const Icon(Icons.restaurant_menu_rounded, color: AppColors.textPrimary),
        SizedBox(width: SizeConfig.width * 0.03),
        Text(
          "Your Daily Meals",
          style: AppTextStyles.title20BlackBold,
        ),
      ],
    );
  }

  Widget _buildMealsList(dynamic plan) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
      itemCount: plan.meals.length,
      itemBuilder: (context, index) => MealSectionCard(
        meal: plan.meals[index],
        index: index,
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, NutritionSuccess state) {
    return FadeInUp(
      delay: const Duration(milliseconds: 800),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            context.read<NutritionCubit>().savePlan(state.plan);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, SizeConfig.height * 0.075),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark_added_rounded, size: 24),
              SizedBox(width: SizeConfig.width * 0.03),
              const Text(
                "Save Daily Plan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
