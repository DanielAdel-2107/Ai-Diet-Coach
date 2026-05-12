import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/view_models/food_scanner_cubit/food_scanner_cubit.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/view_models/food_scanner_cubit/food_scanner_state.dart';
import 'package:ai_diet_coach/core/app_route/route_names.dart';

class FoodScannerScreenBody extends StatefulWidget {
  const FoodScannerScreenBody({super.key});

  @override
  State<FoodScannerScreenBody> createState() => _FoodScannerScreenBodyState();
}

class _FoodScannerScreenBodyState extends State<FoodScannerScreenBody> {
  final TextEditingController _gramController = TextEditingController(
    text: "100",
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _gramController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodScannerCubit, FoodScannerState>(
      listener: (context, state) {
        if (state is FoodScannerAnalyzing) {
          CustomQuickAlert.loading();
        } else if (state is FoodScannerFailure) {
          Navigator.pop(context); // Close loading dialog
          CustomQuickAlert.error(title: "Oops!", message: state.error);
        } else if (state is FoodScannerSuccess) {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            RouteNames.foodAnalysisResultsScreen,
            arguments: {
              'analysis': state.analysis,
              'cubit': context.read<FoodScannerCubit>(),
            },
          ).then((_) {
            if (context.mounted) {
              context.read<FoodScannerCubit>().reset();
            }
          });
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: SizeConfig.height * 0.03),

              // الجزء الرئيسي المتغير (يأخذ باقي المساحة)
              Expanded(
                child: state is FoodScannerInitial
                    ? _buildImagePicker(context)
                    : _buildPreviewAndInput(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
      child: Row(
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
          Text("AI Food Scanner", style: AppTextStyles.title24BlackBold),
        ],
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
      child: FadeInUp(
        child: Column(
          children: [
            Expanded(child: _buildViewfinderPlaceholder()),
            SizedBox(height: SizeConfig.height * 0.04),
            _buildSourceSelectors(context),
            SizedBox(height: SizeConfig.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildViewfinderPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._buildCornerMarkers(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Animate(
                onPlay: (controller) => controller.repeat(reverse: true),
                effects: [
                  ScaleEffect(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds,
                  ),
                  FadeEffect(begin: 0.6, end: 1.0, duration: 2.seconds),
                ],
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.center_focus_weak_rounded,
                    size: SizeConfig.width * 0.2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.height * 0.03),
              Text(
                "Scan Food to Analyze",
                style: AppTextStyles.title20BlackBold,
              ),
              SizedBox(height: SizeConfig.height * 0.01),
              Text(
                "Position food clearly within frame",
                style: AppTextStyles.title16GreyW500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    double size = 50;
    double thickness = 6;
    return [
      Positioned(
        top: 25,
        left: 25,
        child: _buildCorner(
          top: true,
          left: true,
          size: size,
          thickness: thickness,
        ),
      ),
      Positioned(
        top: 25,
        right: 25,
        child: _buildCorner(
          top: true,
          left: false,
          size: size,
          thickness: thickness,
        ),
      ),
      Positioned(
        bottom: 25,
        left: 25,
        child: _buildCorner(
          top: false,
          left: true,
          size: size,
          thickness: thickness,
        ),
      ),
      Positioned(
        bottom: 25,
        right: 25,
        child: _buildCorner(
          top: false,
          left: false,
          size: size,
          thickness: thickness,
        ),
      ),
    ];
  }

  Widget _buildCorner({
    required bool top,
    required bool left,
    required double size,
    required double thickness,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
          bottom: !top
              ? BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
          left: left
              ? BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
          right: !left
              ? BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSourceSelectors(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPickerButton(
            context,
            "Camera",
            Icons.camera_alt_rounded,
            ImageSource.camera,
            isPrimary: true,
          ),
        ),
        SizedBox(width: SizeConfig.width * 0.04),
        Expanded(
          child: _buildPickerButton(
            context,
            "Gallery",
            Icons.photo_library_rounded,
            ImageSource.gallery,
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerButton(
    BuildContext context,
    String label,
    IconData icon,
    ImageSource source, {
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: () => context.read<FoodScannerCubit>().pickImage(source),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : AppColors.card,
        foregroundColor: isPrimary ? Colors.white : AppColors.primary,
        minimumSize: Size(double.infinity, SizeConfig.height * 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1.5,
                ),
        ),
        elevation: isPrimary ? 8 : 0,
        shadowColor: AppColors.primary.withOpacity(0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewAndInput(BuildContext context, FoodScannerState state) {
    File? imageFile;
    if (state is FoodScannerImagePicked) imageFile = state.image;
    if (state is FoodScannerAnalyzing) imageFile = state.image;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
      child: FadeInUp(
        child: Column(
          children: [
            // منطقة الصورة
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (imageFile != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.file(
                          imageFile,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (state is FoodScannerAnalyzing) _buildScanningOverlay(),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.height * 0.03),

            _buildGramInput(),

            SizedBox(height: SizeConfig.height * 0.02),

            TextButton.icon(
              onPressed: () => context.read<FoodScannerCubit>().reset(),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                "Discard and Retake",
                style: TextStyle(fontSize: 16),
              ),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),

            SizedBox(height: SizeConfig.height * 0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          Animate(
            onPlay: (controller) => controller.repeat(),
            effects: [
              MoveEffect(
                begin: const Offset(0, -200),
                end: const Offset(0, 400),
                duration: 2.seconds,
              ),
            ],
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.0),
                    AppColors.primary.withOpacity(0.5),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 4,
                  width: double.infinity,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGramInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.scale_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: SizeConfig.width * 0.04),
          Expanded(
            child: TextFormField(
              controller: _gramController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              style: AppTextStyles.title20BlackBold,
              decoration: InputDecoration(
                hintText: "Weight",
                hintStyle: AppTextStyles.title16GreyW500,
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("grams", style: AppTextStyles.title16PrimaryGreenW600),
          ),
        ],
      ),
    );
  }
}
