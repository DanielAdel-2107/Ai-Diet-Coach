import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/core/app_route/route_names.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/dashboard/view_models/dashboard_cubit/dashboard_cubit.dart';
import 'package:ai_diet_coach/features/patient/dashboard/view_models/dashboard_cubit/dashboard_state.dart';
import 'package:ai_diet_coach/features/patient/dashboard/views/widgets/stats_grid.dart';
import 'package:ai_diet_coach/features/patient/dashboard/views/widgets/ai_chat_card.dart';
import 'package:ai_diet_coach/features/patient/dashboard/views/widgets/calories_card.dart';
import 'package:ai_diet_coach/features/patient/dashboard/views/widgets/quick_actions_section.dart';

class PatientDashboardScreenBody extends StatelessWidget {
  const PatientDashboardScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardSuccess) {
          final data = state.data;
          return RefreshIndicator(
            onRefresh: () async => context.read<DashboardCubit>().refresh(),
            color: AppColors.primary,
            child: Stack(
              children: [
                // Curved Gradient Background
                Container(
                  height: SizeConfig.height * 0.4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                SafeArea(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(SizeConfig.width * 0.05),
                              child: _buildHeader(context, data.userName),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
                              child: CaloriesCard(
                                current: data.caloriesToday,
                                goal: data.caloriesGoal,
                              ),
                            ),
                            SizedBox(height: SizeConfig.height * 0.04),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
                              child: StatsGrid(
                                workoutPlan: data.workoutPlan,
                                nutritionPlan: data.nutritionPlan,
                                sugarLevel: data.sugarLevel,
                                sugarStatus: data.sugarStatus,
                                onWorkoutTap: () => Navigator.pushNamed(context, RouteNames.workoutPlanScreen),
                                onNutritionTap: () => Navigator.pushNamed(context, RouteNames.nutritionScreen),
                                onSugarTap: () => Navigator.pushNamed(context, RouteNames.sugarTrackingScreen),
                                onMoreInfoTap: () => Navigator.pushNamed(context, RouteNames.progressScreen),
                              ),
                            ),
                            SizedBox(height: SizeConfig.height * 0.04),
                            QuickActionsSection(
                              onScan: () => Navigator.pushNamed(context, RouteNames.foodScannerScreen),
                              onAddMeal: () => Navigator.pushNamed(context, RouteNames.savedMealsScreen),
                              onStartWorkout: () => Navigator.pushNamed(context, RouteNames.workoutScreen),
                            ),
                            SizedBox(height: SizeConfig.height * 0.04),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
                              child: const AIChatCard(),
                            ),
                            SizedBox(height: SizeConfig.height * 0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is DashboardFailure) {
           return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(state.error, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.read<DashboardCubit>().refresh(),
                  child: const Text("Retry Connection"),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return FadeInDown(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: SizeConfig.width * 0.07,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
              ),
              SizedBox(width: SizeConfig.width * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Good Morning,", style: AppTextStyles.title16White70),
                  Text(name, style: AppTextStyles.title24WhiteBold),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, RouteNames.remindersScreen),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
