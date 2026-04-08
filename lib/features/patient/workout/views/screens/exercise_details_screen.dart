import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/workout/models/exercise_model.dart';
import 'package:shimmer/shimmer.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseDetailsScreen({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildExerciseContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: SizeConfig.height * 0.45,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
             Hero(
               tag: 'exercise_${exercise.id}',
               child: Container(
                 color: Colors.white,
                 child: Image.network(
                  exercise.gifUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                       baseColor: Colors.grey.shade200,
                       highlightColor: Colors.grey.shade100,
                       child: Container(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.fitness_center_rounded, size: 80, color: AppColors.primary)),
                 ),
               ),
             ),
             Positioned(
               bottom: -1,
               left: 0,
               right: 0,
               height: 60,
               child: Container(
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     begin: Alignment.topCenter,
                     end: Alignment.bottomCenter,
                     colors: [
                       AppColors.scaffoldBackground.withOpacity(0.0),
                       AppColors.scaffoldBackground,
                     ]
                   )
                 ),
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseContent(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.height * 0.02),
            FadeInUp(
              child: Text(
                exercise.name,
                style: AppTextStyles.title26BlackBold.copyWith(fontSize: 30, height: 1.2),
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.03),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Row(
                children: [
                  Expanded(child: _buildInfoCard("Body Part", exercise.bodyPart.toUpperCase(), Icons.accessibility_new_rounded, AppColors.secondary)),
                  SizedBox(width: SizeConfig.width * 0.04),
                  Expanded(child: _buildInfoCard("Equipment", exercise.equipment.toUpperCase(), Icons.fitness_center_rounded, AppColors.chartOrange)),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.04),
            _buildInstructionsSection(),
            SizedBox(height: SizeConfig.height * 0.04),
            if (exercise.videoUrl.isNotEmpty) ...[
               FadeInUp(
                 delay: const Duration(milliseconds: 400),
                 child: _buildVideoButton(context),
               ),
               SizedBox(height: SizeConfig.height * 0.06),
            ],
            SizedBox(height: SizeConfig.height * 0.04),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
             ),
             child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: SizeConfig.height * 0.015),
          Text(title, style: AppTextStyles.title12Grey),
          SizedBox(height: SizeConfig.height * 0.005),
          Text(subtitle, style: AppTextStyles.title16BlackBold.copyWith(fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildVideoButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _launchURL(exercise.videoUrl),
      icon: const Icon(Icons.play_circle_fill_rounded, size: 28),
      label: const Text("Watch Video Tutorial", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, SizeConfig.height * 0.075),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.redAccent.withOpacity(0.3),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildInstructionsSection() {
    // Split instructions by period to create "steps" if possible
    final steps = exercise.instructions.split('. ').where((s) => s.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 200),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Text(
                "How to perform",
                style: AppTextStyles.title20BlackBold.copyWith(fontSize: 22),
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.height * 0.03),
        ...steps.asMap().entries.map((entry) {
          int idx = entry.key;
          String text = entry.value;
          if (!text.endsWith('.')) text += '.';
          
          return FadeInUp(
            delay: Duration(milliseconds: 100 * (idx + 3)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "0${idx + 1}",
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  SizedBox(width: SizeConfig.width * 0.04),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTextStyles.title14Grey.copyWith(
                        color: Colors.black87,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
