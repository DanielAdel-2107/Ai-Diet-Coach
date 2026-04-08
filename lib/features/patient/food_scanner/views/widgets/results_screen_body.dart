import 'package:animate_do/animate_do.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/models/food_analysis_model.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/view_models/food_scanner_cubit/food_scanner_cubit.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/view_models/food_scanner_cubit/food_scanner_state.dart';

class FoodAnalysisResultsBody extends StatefulWidget {
  final FoodAnalysisModel analysis;

  const FoodAnalysisResultsBody({super.key, required this.analysis});

  @override
  State<FoodAnalysisResultsBody> createState() => _FoodAnalysisResultsBodyState();
}

class _FoodAnalysisResultsBodyState extends State<FoodAnalysisResultsBody> {
  late FoodAnalysisModel currentAnalysis;
  final TextEditingController _weightController = TextEditingController();
  bool _isLogged = false;
  bool _isLoadingDialogActive = false;

  @override
  void initState() {
    super.initState();
    currentAnalysis = widget.analysis;
    _weightController.text = currentAnalysis.grams.toInt().toString();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SizeConfig.init(context);
  }

  void _safePop() {
    if (_isLoadingDialogActive && mounted) {
      Navigator.of(context).pop();
      _isLoadingDialogActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodScannerCubit, FoodScannerState>(
      listener: (context, state) {
        if (state is FoodScannerSavedSuccess) {
          _safePop();
          if (mounted) {
            setState(() => _isLogged = true);
          }
          CustomQuickAlert.success(
            title: "Logged!",
            message: "Meal added to your daily progress.",
          );
        } else if (state is FoodScannerFailure) {
          _safePop();
          CustomQuickAlert.error(title: "Oops!", message: state.error);
        } else if (state is FoodScannerSuccess) {
          _safePop();
          if (mounted) {
            setState(() {
              currentAnalysis = state.analysis;
              _isLogged = false; // Reset if they re-calculate
              _weightController.text = currentAnalysis.grams.toInt().toString();
            });
          }
        } else if (state is FoodScannerAnalyzing || state is FoodScannerSaving) {
          if (!_isLoadingDialogActive) {
            _isLoadingDialogActive = true;
            CustomQuickAlert.loading();
          }
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.scaffoldBackground,
                    AppColors.primary.withOpacity(0.08),
                    AppColors.scaffoldBackground,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                   _buildTopNavBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFoodInfoCard(),
                          SizedBox(height: SizeConfig.height * 0.03),
                          _buildCalorieHero(),
                          SizedBox(height: SizeConfig.height * 0.04),
                          _buildMacrosSection(),
                          SizedBox(height: SizeConfig.height * 0.15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildStickyActions(context),
          ],
        );
      },
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.width * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.close_rounded, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(12),
            ),
          ),
          Text("Meal Insight", style: AppTextStyles.title20BlackBold),
          const SizedBox(width: 52),
        ],
      ),
    );
  }

  Widget _buildFoodInfoCard() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 26),
            ),
            SizedBox(width: SizeConfig.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentAnalysis.foodName,
                    style: AppTextStyles.title20BlackBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.scale_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        "${currentAnalysis.grams.toInt()}g Portion",
                        style: AppTextStyles.title14Grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildWeightEditor(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightEditor() {
    return GestureDetector(
      onTap: _showWeightAdjustmentDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            const Text("Adjust", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.edit_rounded, color: AppColors.primary, size: 14),
          ],
        ),
      ),
    );
  }

  void _showWeightAdjustmentDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Adjust Meal Weight"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                suffixText: "grams",
                filled: true,
                fillColor: AppColors.scaffoldBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                double grams = double.tryParse(_weightController.text) ?? currentAnalysis.grams;
                context.read<FoodScannerCubit>().analyzeFood(grams);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Recalculate AI Results", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieHero() {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              "ESTIMATED CALORIES",
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            SizedBox(height: SizeConfig.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  currentAnalysis.calories.toInt().toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 84, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 8),
                const Text(
                  "kcal",
                  style: TextStyle(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ).animate().shimmer(duration: 2.seconds, colors: [Colors.white, Colors.white24, Colors.white]),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text("Nutrients Analysis", style: AppTextStyles.title18BlackBold),
          ],
        ),
        SizedBox(height: SizeConfig.height * 0.02),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildMacroCard("Protein", "${currentAnalysis.protein}g", AppColors.chartBlue, Icons.bolt_rounded, 0),
            _buildMacroCard("Carbs", "${currentAnalysis.carbs}g", AppColors.chartOrange, Icons.grain_rounded, 1),
            _buildMacroCard("Fat", "${currentAnalysis.fat}g", AppColors.chartGreen, Icons.opacity_rounded, 2),
            _buildMacroCard("Fiber", "${currentAnalysis.fiber}g", AppColors.accent, Icons.eco_rounded, 3),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String label, String value, Color color, IconData icon, int index) {
    return FadeInLeft(
      delay: Duration(milliseconds: 300 + (index * 100)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(label, style: AppTextStyles.title14Grey),
              ],
            ),
            const Spacer(),
            Text(value, style: AppTextStyles.title20BlackBold.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyActions(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(SizeConfig.width * 0.05, 20, SizeConfig.width * 0.05, SizeConfig.height * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLogged 
            ? () => CustomQuickAlert.warning(
              title: "Already Added",
              message: "This meal is already in your daily log!",
            )
            : () => context.read<FoodScannerCubit>().saveToLog(currentAnalysis),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLogged ? AppColors.textSecondary : AppColors.textPrimary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, SizeConfig.height * 0.075),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: AppColors.textPrimary.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isLogged ? Icons.verified_rounded : Icons.check_circle_rounded),
              const SizedBox(width: 12),
              Text(
                _isLogged ? "Logged Successfully" : "Log to Daily Tracker", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
