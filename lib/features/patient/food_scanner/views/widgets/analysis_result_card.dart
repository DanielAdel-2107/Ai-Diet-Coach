import 'package:flutter/material.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/models/food_analysis_model.dart';

class AnalysisResultCard extends StatelessWidget {
  final FoodAnalysisModel analysis;
  final VoidCallback onSave;
  final bool isSaving;

  const AnalysisResultCard({
    super.key,
    required this.analysis,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.width * 0.06),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: SizeConfig.height * 0.03),
          _buildCaloriesCircle(),
          SizedBox(height: SizeConfig.height * 0.04),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: SizeConfig.height * 0.03),
          _buildMacrosGrid(),
          SizedBox(height: SizeConfig.height * 0.04),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        SizedBox(width: SizeConfig.width * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("AI Analysis Result", style: AppTextStyles.title12Grey.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              SizedBox(height: SizeConfig.height * 0.005),
              Text(
                analysis.foodName,
                style: AppTextStyles.title22BlackW600,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesCircle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("Portion: ${analysis.grams}g", style: AppTextStyles.title14WhiteW600),
              ),
              SizedBox(height: SizeConfig.height * 0.02),
              const Text("Total Energy", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(
                "${analysis.calories.toInt()} kcal",
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.2),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: AppColors.accent, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosGrid() {
    return Column(
      children: [
        Row(
          children: [
             Expanded(child: _buildMacroCard("Protein", analysis.protein, AppColors.chartBlue, Icons.fitness_center_rounded)),
             SizedBox(width: SizeConfig.width * 0.04),
             Expanded(child: _buildMacroCard("Carbs", analysis.carbs, AppColors.chartOrange, Icons.grass_rounded)),
          ],
        ),
        SizedBox(height: SizeConfig.width * 0.04),
        Row(
          children: [
             Expanded(child: _buildMacroCard("Fats", analysis.fat, AppColors.chartGreen, Icons.water_drop_rounded)),
             SizedBox(width: SizeConfig.width * 0.04),
             Expanded(child: _buildMacroCard("Fiber", analysis.fiber, AppColors.accent, Icons.eco_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              Text(
                "${value}g",
                style: AppTextStyles.title16BlackBold.copyWith(color: color),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.height * 0.015),
          Text(label, style: AppTextStyles.title14Grey),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: isSaving ? null : onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textPrimary,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, SizeConfig.height * 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSaving)
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          else ...[
            const Icon(Icons.add_task_rounded, size: 24),
            const SizedBox(width: 8),
            const Text(
              "Add to Daily Log",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ],
      ),
    );
  }
}
