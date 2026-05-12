import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/view_models/sugar_cubit/sugar_cubit.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/view_models/sugar_cubit/sugar_state.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/views/widgets/sugar_stats_header.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/views/widgets/sugar_chart_section.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/views/widgets/sugar_entries_list.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/views/widgets/sugar_add_fab.dart';
import 'package:ai_diet_coach/core/app_route/route_names.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/views/widgets/add_sugar_entry_dialog.dart';

import 'package:custom_quick_alert/custom_quick_alert.dart';

class SugarTrackingBody extends StatelessWidget {
  const SugarTrackingBody({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return BlocProvider(
      create: (context) => SugarCubit()..loadSugarLevels(),
      child: BlocConsumer<SugarCubit, SugarState>(
        listener: (context, state) {
          if (state is SugarAdding) {
            CustomQuickAlert.loading();
          } else if (state is SugarAddedSuccess) {
            Navigator.pop(context); // Close the loading dialog
            CustomQuickAlert.success(
              title: 'Success',
              message: 'Sugar level reading saved successfully!',
            );
          } else if (state is SugarSuccess) {
            // Initial data loaded or refresh complete
          } else if (state is SugarFailure) {
            // Close loading dialog if it was triggered by SugarAdding
            if (state.error.contains('Reload failed') || state.error.contains('Failed to add')) {
               Navigator.pop(context);
            }
            CustomQuickAlert.error(
              title: 'Error',
              message: state.error,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Stack(
              children: [
                // Decorative background blobs
                Positioned(
                  top: -40,
                  right: -60,
                  child: Container(
                    width: SizeConfig.width * 0.6,
                    height: SizeConfig.width * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -80,
                  child: Container(
                    width: SizeConfig.width * 0.5,
                    height: SizeConfig.width * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.chartBlue.withOpacity(0.06),
                    ),
                  ),
                ),
                SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: _buildHeader(context),
                      ),
                      // Content based on state
                      if (state is SugarLoading)
                        SliverFillRemaining(
                          child: _buildLoadingState(),
                        )
                      else if (state is SugarSuccess) ...[
                        SliverToBoxAdapter(
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            child: SugarStatsHeader(
                              levels: state.levels,
                              average: state.average,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            child: SugarChartSection(levels: state.levels),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            child: SugarEntriesList(levels: state.levels),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: SizeConfig.height * 0.12),
                        ),
                      ] else if (state is SugarFailure)
                        SliverFillRemaining(
                          child: _buildErrorState(state.error),
                        )
                      else
                        SliverFillRemaining(
                          child: _buildEmptyState(),
                        ),
                    ],
                  ),
                ),
                // Floating Action Button
                Positioned(
                  bottom: SizeConfig.height * 0.03,
                  right: SizeConfig.width * 0.05,
                  child: SugarAddFab(
                    onAdd: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: BlocProvider.of<SugarCubit>(context),
                          child: const AddSugarEntryDialog(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.width * 0.05,
        vertical: SizeConfig.height * 0.02,
      ),
      child: FadeInDown(
        duration: const Duration(milliseconds: 350),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: SizeConfig.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sugar Tracker',
                    style: AppTextStyles.title24BlackBold.copyWith(
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Monitor your glucose levels',
                    style: AppTextStyles.title14Grey,
                  ),
                ],
              ),
            ),
            // Bluetooth Device Button
            GestureDetector(
              onTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  RouteNames.sugarDeviceScreen,
                );
                if (result == true && context.mounted) {
                  context.read<SugarCubit>().loadSugarLevels();
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bluetooth_searching_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.height * 0.025),
          Text('Loading your data...', style: AppTextStyles.title16BlackBold),
          SizedBox(height: SizeConfig.height * 0.01),
          Text('Fetching sugar readings', style: AppTextStyles.title14Grey),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: SizeConfig.height * 0.03),
              Text(
                'No readings yet',
                style: AppTextStyles.title20BlackBold,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.height * 0.012),
              Text(
                'Start tracking your glucose levels by tapping the + button below.',
                style: AppTextStyles.title14Grey.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.02),
            Text('Something went wrong', style: AppTextStyles.title18BlackBold),
            SizedBox(height: SizeConfig.height * 0.01),
            Text(
              error,
              style: AppTextStyles.title14Grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
