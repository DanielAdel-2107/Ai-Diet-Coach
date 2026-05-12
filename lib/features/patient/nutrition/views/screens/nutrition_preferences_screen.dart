import 'package:ai_diet_coach/core/components/custom_app_bar.dart';
import 'package:ai_diet_coach/core/components/custom_elevated_button.dart';
import 'package:ai_diet_coach/core/components/custom_text_form_field_with_title.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/nutrition/view_models/nutrition_cubit/nutrition_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';

class NutritionPreferencesScreen extends StatefulWidget {
  const NutritionPreferencesScreen({super.key});

  @override
  State<NutritionPreferencesScreen> createState() => _NutritionPreferencesScreenState();
}

class _NutritionPreferencesScreenState extends State<NutritionPreferencesScreen> {
  final TextEditingController _likedController = TextEditingController();
  final TextEditingController _dislikedController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  @override
  void dispose() {
    _likedController.dispose();
    _dislikedController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Dietary Preferences'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                "Tell us more about your food choices to generate a perfect plan for you.",
                style: AppTextStyles.title16GreyW500,
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.04),
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: CustomTextFormFieldWithTitle(
                title: "Foods You Love",
                labelText: "e.g., Chicken, Salmon, Avocado",
                controller: _likedController,
                maxLines: 3,
                enableValidator: false,
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.03),
            FadeInLeft(
              delay: const Duration(milliseconds: 400),
              child: CustomTextFormFieldWithTitle(
                title: "Foods to Avoid",
                labelText: "e.g., Red meat, Dairy, Fried food",
                controller: _dislikedController,
                maxLines: 3,
                enableValidator: false,
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.03),
            FadeInLeft(
              delay: const Duration(milliseconds: 600),
              child: CustomTextFormFieldWithTitle(
                title: "Allergies",
                labelText: "e.g., Nuts, Shellfish, Gluten",
                controller: _allergiesController,
                maxLines: 2,
                enableValidator: false,
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.06),
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: () {
                    final liked = _likedController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    final disliked = _dislikedController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    final allergies = _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

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
                    );
                    Navigator.pop(context);
                  },
                  name: "Generate My Plan",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
