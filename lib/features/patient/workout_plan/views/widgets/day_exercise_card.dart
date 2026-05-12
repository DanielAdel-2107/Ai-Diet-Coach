import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/view_models/workout_plan_cubit/workout_plan_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/models/workout_plan_model.dart';

class DayExerciseCard extends StatelessWidget {
  final ExercisePlan exercise;
  final int index;

  const DayExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: 50 * index),
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.height * 0.015),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildPlayThumbnail(),
            const SizedBox(width: 16),
            Expanded(child: _buildExerciseInfo()),
            _buildIntensityBadge(),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                context.read<WorkoutPlanCubit>().completeExercise(exercise);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logged: ${exercise.name}"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
              style: IconButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayThumbnail() {
    return Container(
      height: 75,
      width: 75,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            "${index + 1}",
            style: TextStyle(
              color: AppColors.primary.withOpacity(0.2),
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.name,
          style: AppTextStyles.title16BlackBold.copyWith(fontSize: 18, letterSpacing: -0.2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDetailTip(Icons.repeat_rounded, "${exercise.sets} Sets", AppColors.secondary),
            _buildDetailTip(Icons.fitness_center_rounded, "${exercise.reps} Reps", AppColors.chartOrange),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailTip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityBadge() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getIntensityColor().withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.bolt_rounded, color: _getIntensityColor(), size: 22),
    );
  }

  Color _getIntensityColor() {
    switch (exercise.intensity.toLowerCase()) {
      case 'high': return Colors.redAccent;
      case 'moderate': return Colors.orangeAccent;
      default: return AppColors.primary;
    }
  }
}
