import 'package:ai_diet_coach/core/components/custom_elevated_button.dart';
import 'package:ai_diet_coach/core/utils/assets/lotties/app_lotties.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/nutrition/view_models/nutrition_cubit/nutrition_cubit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class NutritionInitialForm extends StatefulWidget {
  const NutritionInitialForm({super.key});

  @override
  State<NutritionInitialForm> createState() => _NutritionInitialFormState();
}

class _NutritionInitialFormState extends State<NutritionInitialForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _likedController = TextEditingController();
  final TextEditingController _dislikedController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _steps = [
    {
      "title": "What do you love to eat?",
      "subtitle": "We'll prioritize these in your plan.",
      "icon": Icons.favorite_rounded,
      "color": AppColors.primary,
      "hint": "e.g., Salmon, Avocado, Chicken...",
    },
    {
      "title": "Anything to avoid?",
      "subtitle": "We'll keep these away from your meals.",
      "icon": Icons.do_not_disturb_on_rounded,
      "color": Colors.orange,
      "hint": "e.g., Red meat, Dairy, Fried food...",
    },
    {
      "title": "Any allergies?",
      "subtitle": "Safety first! Please list them clearly.",
      "icon": Icons.warning_amber_rounded,
      "color": Colors.redAccent,
      "hint": "e.g., Peanuts, Gluten, Shellfish...",
    },
    {
      "title": "Anything else?",
      "subtitle": "Custom preferences or diet types (e.g. Keto, Vegan).",
      "icon": Icons.edit_note_rounded,
      "color": AppColors.secondary,
      "hint": "e.g., I want high protein meals only...",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _likedController.dispose();
    _dislikedController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _startGeneration();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _startGeneration() {
    final liked = _likedController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final disliked = _dislikedController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final allergies = _allergiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final notes = _notesController.text.trim();

    final cubit = context.read<NutritionCubit>();
    cubit.savePreferences(
      likedFoods: liked,
      dislikedFoods: disliked,
      allergies: allergies,
    );
    cubit.generatePlan(
      likedFoods: liked,
      dislikedFoods: disliked,
      allergies: allergies,
      additionalNotes: notes, // Pass notes to generatePlan
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: SizeConfig.height * 0.02),
        _buildProgressIndicator(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return _buildStepPage(index);
            },
          ),
        ),
        _buildNavigationButtons(),
        SizedBox(height: SizeConfig.height * 0.04),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.1),
      child: Row(
        children: List.generate(_steps.length, (index) {
          bool isActive = index <= _currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 10,
                        )
                      ]
                    : [],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepPage(int index) {
    final step = _steps[index];
    final controller = index == 0
        ? _likedController
        : index == 1
            ? _dislikedController
            : index == 2
                ? _allergiesController
                : _notesController;

    return Padding(
      padding: EdgeInsets.all(SizeConfig.width * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ZoomIn(
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Icon(step['icon'], color: Colors.white, size: 80),
            ),
          ),
          SizedBox(height: SizeConfig.height * 0.04),
          FadeInDown(
            child: Text(
              step['title'],
              textAlign: TextAlign.center,
              style: AppTextStyles.title24WhiteBold,
            ),
          ),
          SizedBox(height: SizeConfig.height * 0.015),
          FadeInUp(
            child: Text(
              step['subtitle'],
              textAlign: TextAlign.center,
              style: AppTextStyles.title16GreyW500.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          SizedBox(height: SizeConfig.height * 0.06),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: TextField(
                controller: controller,
                maxLines: 3,
                style: AppTextStyles.title18Black,
                decoration: InputDecoration(
                  hintText: step['hint'],
                  hintStyle: AppTextStyles.title16Grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            FadeInLeft(
              child: IconButton(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            )
          else
            const SizedBox(width: 60),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeInUp(
                child: CustomElevatedButton(
                  onPressed: _nextPage,
                  name: _currentPage == _steps.length - 1
                      ? "Create My Plan ✨"
                      : "Next Step",
                  backgroundColor: Colors.white,
                  forgroundColor: AppColors.primary,
                  textStyle: AppTextStyles.title18PrimaryColorW700,
                  hPadding: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
