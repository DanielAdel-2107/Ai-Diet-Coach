import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/workout/view_models/workout_cubit/workout_cubit.dart';
import 'package:ai_diet_coach/features/patient/workout/view_models/workout_cubit/workout_state.dart';
import 'package:ai_diet_coach/features/patient/workout/views/widgets/exercise_card.dart';
import 'package:ai_diet_coach/features/patient/workout/views/screens/exercise_details_screen.dart';

class WorkoutScreenBody extends StatelessWidget {
  const WorkoutScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        return Stack(
          children: [
            // Decorative background
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 100),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildMotivationalBanner(),
                  _buildCategoryFilters(context, state),
                  Expanded(
                    child: _buildWorkoutList(context, state),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05, vertical: SizeConfig.height * 0.02),
      child: FadeInDown(
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
              "Workout Hub",
              style: AppTextStyles.title26BlackBold.copyWith(letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalBanner() {
    return FadeInRight(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05, vertical: SizeConfig.height * 0.01),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [AppColors.textPrimary, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text("Ready to sweat?", style: AppTextStyles.title14WhiteW600.copyWith(color: Colors.white70)),
                    const SizedBox(height: 8),
                    const Text("Find the perfect\nroutine today", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2)),
                 ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 36),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context, WorkoutState state) {
    if (state is! WorkoutLoaded) {
      return const SizedBox.shrink();
    }
    
    final categories = state.categories;
    final activeCategory = state.activeCategory;

    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      child: Container(
        height: 50,
        margin: EdgeInsets.only(top: SizeConfig.height * 0.02, bottom: SizeConfig.height * 0.01),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isActive = activeCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () {
                  context.read<WorkoutCubit>().filterByCategory(category);
                },
                borderRadius: BorderRadius.circular(25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.card,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isActive
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                        : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                    border: isActive ? null : Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context, WorkoutState state) {
    if (state is WorkoutLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    } else if (state is WorkoutFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(state.error, style: AppTextStyles.title16GreyW500),
          ],
        ),
      );
    } else if (state is WorkoutLoaded) {
      if (state.exercises.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.search_off_rounded, color: Colors.grey.shade300, size: 80),
               const SizedBox(height: 16),
               const Text("No exercises found.", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }
      return FadeInUp(
        child: ListView.builder(
          padding: EdgeInsets.only(
             left: SizeConfig.width * 0.05, 
             right: SizeConfig.width * 0.05,
             top: SizeConfig.height * 0.02,
             bottom: SizeConfig.height * 0.05,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: state.exercises.length,
          itemBuilder: (context, index) {
            final exercise = state.exercises[index];
            return ExerciseCard(
              exercise: exercise,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailsScreen(exercise: exercise),
                  ),
                );
              },
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
