import 'package:animate_do/animate_do.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/view_models/workout_plan_cubit/workout_plan_cubit.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/view_models/workout_plan_cubit/workout_plan_state.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/views/widgets/day_exercise_card.dart';

class WorkoutPlanBody extends StatelessWidget {
  const WorkoutPlanBody({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    
    return BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
      listener: (context, state) {
        if (state is WorkoutPlanFailure) {
          CustomQuickAlert.error(title: "Oops!", message: state.error);
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Positioned(
              top: -50,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, state),
                  if (state is WorkoutPlanLoaded) ...[
                    _buildDaySelector(
                      context,
                      state.plan,
                      state.selectedDayIndex,
                    ),
                    Expanded(
                      child: _buildExercisesList(
                        context,
                        state.plan.days[state.selectedDayIndex],
                      ),
                    ),
                  ] else if (state is WorkoutPlanLoading) ...[
                    Expanded(child: _buildLoadingState()),
                  ] else ...[
                    Expanded(child: _buildInitialState(context)),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WorkoutPlanState state) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.width * 0.05,
        vertical: SizeConfig.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
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
                    "Workout Plan",
                    style: AppTextStyles.title26BlackBold.copyWith(
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (state is WorkoutPlanLoaded)
                IconButton(
                  onPressed: () => _showRegenerateDialog(context),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
          if (state is WorkoutPlanLoaded) ...[
            SizedBox(height: SizeConfig.height * 0.03),
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "AI Personalized Strategy",
                            style: AppTextStyles.title12PrimaryColorW500,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.plan.objective,
                            style: AppTextStyles.title14BlackColorW600.copyWith(
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRegenerateDialog(BuildContext context) {
    CustomQuickAlert.warning(
      title: "Regenerate Plan?",
      message: "This will replace your current weekly plan with a brand new one. Continue?",
      onConfirm: () {
        Navigator.pop(context);
        context.read<WorkoutPlanCubit>().generateAndSavePlan();
      },
    );
  }

  Widget _buildDaySelector(
    BuildContext context,
    dynamic plan,
    int currentIndex,
  ) {
    return FadeInLeft(
      child: Container(
        height: 100,
        margin: EdgeInsets.only(
          top: SizeConfig.height * 0.01,
          bottom: SizeConfig.height * 0.02,
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
          itemCount: plan.days.length,
          itemBuilder: (context, index) {
            final day = plan.days[index];
            final isSelected = index == currentIndex;
            return GestureDetector(
              onTap: () => context.read<WorkoutPlanCubit>().selectDay(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 75,
                margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppColors.textPrimary, Colors.black87],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 5,
                          ),
                        ],
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDayName(day.day),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w900,
                        fontSize: _getDayFontSize(day.day),
                      ),
                    ),
                    if (day.day.contains(RegExp(r'\d')))
                      Text(
                        day.day.replaceAll(RegExp(r'\D'), ''),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : AppColors.textSecondary.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        day.isRestDay
                            ? Icons.bedtime_rounded
                            : Icons.fitness_center_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, dynamic dayWorkout) {
    if (dayWorkout.isRestDay) {
      return FadeInUp(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: SizeConfig.height * 0.02),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.self_improvement_rounded,
                        size: 60,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text("Recovery Day", style: AppTextStyles.title24BlackBold),
                    const SizedBox(height: 8),
                    Text(
                      "Muscles grow when you let them rest. Today is dedicated to recharging your body.",
                      style: AppTextStyles.title14Grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildRecoveryTip(
                title: "Hydration Focus",
                desc: "Drink 2-3L of water today to flush out toxins and aid muscle repair.",
                icon: Icons.water_drop_rounded,
              ),
              const SizedBox(height: 16),
              _buildRecoveryTip(
                title: "Sleep Optimization",
                desc: "Aim for 8 hours of quality sleep tonight for full hormonal recovery.",
                icon: Icons.hotel_rounded,
              ),
            ],
          ),
        ),
      );
    }

    return FadeInUp(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.width * 0.05,
          vertical: SizeConfig.height * 0.01,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: dayWorkout.exercises.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildDayFocusCard(dayWorkout);
          }
          return DayExerciseCard(
            exercise: dayWorkout.exercises[index - 1],
            index: index - 1,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 4,
            ),
            SizedBox(height: SizeConfig.height * 0.04),
            Text(
              "AI is crafting your plan...",
              style: AppTextStyles.title20BlackBold,
            ),
            SizedBox(height: SizeConfig.height * 0.01),
            Text(
              "Customizing sets, reps, and exercises based on your profile.",
              style: AppTextStyles.title14Grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: FadeInUp(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: SizeConfig.height * 0.04),
              Text(
                "Ready to Transform?",
                style: AppTextStyles.title26BlackBold,
              ),
              SizedBox(height: SizeConfig.height * 0.02),
              Text(
                "Let our AI generate a personalized 7-day workout schedule optimized for your goals and body type.",
                style: AppTextStyles.title16GreyW500.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.height * 0.06),
              ElevatedButton(
                onPressed: () => context.read<WorkoutPlanCubit>().generateAndSavePlan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, SizeConfig.height * 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: const Text(
                  "Generate AI Plan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDayFocusCard(dynamic dayWorkout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Mission",
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  dayWorkout.focus,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "${dayWorkout.exercises.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Exercises",
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryTip({required String title, required String desc, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title16BlackBold),
                const SizedBox(height: 2),
                Text(desc, style: AppTextStyles.title12Grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDayName(String day) {
    if (day.toLowerCase().trim().startsWith('day')) {
      return "DAY";
    }
    return day.length >= 3 ? day.substring(0, 3).toUpperCase() : day.toUpperCase();
  }

  double _getDayFontSize(String day) {
    if (day.toLowerCase().trim().startsWith('day')) return 10;
    return 14;
  }
}
