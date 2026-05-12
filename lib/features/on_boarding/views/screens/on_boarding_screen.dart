import 'package:ai_diet_coach/core/utils/assets/lotties/app_lotties.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/app_route/route_names.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = const [
    {
      "title": "Smart AI Health Coach",
      "description":
          "Your intelligent assistant for fitness, diet, and healthy living. Ask anything with our AI Chat feature.",
      "image": AppLotties.aiHealthChat,
    },
    {
      "title": "Personalized Nutrition Plans",
      "description":
          "Get customized diet plans based on your body data, goals, and daily activity for optimal results.",
      "image": AppLotties.nutritionDietPlan,
    },
    {
      "title": "Food Recognition & Tracking",
      "description":
          "Take photos of your meals and let AI analyze calories, nutrients, and portion sizes instantly.",
      "image": AppLotties.foodScanAi,
    },
    {
      "title": "Workout Library",
      "description":
          "Explore exercises for each body part with detailed instructions and videos to reach your fitness goals.",
      "image": AppLotties.workoutExerciseLibrary,
    },
    {
      "title": "Health Progress & Sugar Tracking",
      "description":
          "Monitor weight, BMI, calories, and connect your glucose device via Bluetooth for real-time tracking.",
      "image": AppLotties.healthSugarTracking,
    },
    {
      "title": "Smart Reminders",
      "description":
          "Stay on track with reminders for water, meals, workouts, and health checkups.",
      "image": AppLotties.healthReminderNotification,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final bool isLastPage = _currentIndex == onboardingData.length - 1;
    if (isLastPage) {
      _finishOnBoarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onSkip() {
    _finishOnBoarding();
  }

  void _onBack() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finishOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.signInScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;
    final bool isLastPage = _currentIndex == onboardingData.length - 1;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // subtle background circles
            Positioned(
              top: -0.08 * h,
              right: -0.1 * w,
              child: _BlurCircle(
                size: 0.22 * h,
                color: AppColors.primaryLight.withOpacity(0.45),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.05 * w,
                    vertical: 0.01 * h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0.03 * w,
                          vertical: 0.008 * h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.aiGradientStart,
                              AppColors.aiGradientEnd,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'AI Health Coach',
                              style: AppTextStyles.label13WhiteW600,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _SkipButton(onTap: _onSkip),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.05 * w,
                    vertical: 0.005 * h,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your AI-powered\nhealth companion',
                      style: AppTextStyles.title24PrimaryW700,
                    ),
                  ),
                ),
                SizedBox(height: 0.005 * h),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: onboardingData.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = onboardingData[index];
                      return _OnBoardingPage(
                        index: index,
                        currentIndex: _currentIndex,
                        title: item['title'] ?? '',
                        description: item['description'] ?? '',
                        imageName: item['image'] ?? '',
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.05 * w, 0, 0.05 * w, 0.03 * h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PageIndicator(
                        length: onboardingData.length,
                        currentIndex: _currentIndex,
                      ),
                      SizedBox(height: 0.012 * h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step ${_currentIndex + 1} of ${onboardingData.length}',
                            style: AppTextStyles.title15TextSecondary,
                          ),
                          Flexible(
                            child: Text(
                              onboardingData[_currentIndex]['title'] ?? '',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.title13PrimaryGreenW600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.018 * h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 0.017 * h,
                              horizontal: 0.04 * w,
                            ),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: AppTextStyles.title18WhiteW600,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.012 * h),
                      Text(
                        isLastPage
                            ? 'You are all set! Start your healthy journey now.'
                            : 'Swipe to explore more powerful features.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title15TextSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnBoardingPage extends StatelessWidget {
  const _OnBoardingPage({
    required this.index,
    required this.currentIndex,
    required this.title,
    required this.description,
    required this.imageName,
  });

  final int index;
  final int currentIndex;
  final String title;
  final String description;
  final String imageName;

  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;
    final bool isActive = index == currentIndex;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.05 * w, vertical: 0.005 * h),
      child: Column(
        children: [
          SizedBox(height: 0.02 * h),
          Expanded(
            flex: 5,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              scale: isActive ? 1 : 0.94,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 280),
                opacity: isActive ? 1 : 0.65,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.background,
                        AppColors.primaryLight.withOpacity(0.55),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Hero(
                      tag: imageName,
                      transitionOnUserGestures: true,
                      child: Lottie.asset(imageName, fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 0.02 * h),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title22TextPrimaryW600),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: AppTextStyles.body15TextSecondary.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.length, required this.currentIndex});

  final int length;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 22 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isActive
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  )
                : null,
            color: isActive ? null : AppColors.border.withOpacity(0.9),
          ),
        );
      }),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.92),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.title12BlackColor54),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 0.035 * w,
          vertical: 0.007 * h,
        ),
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Skip', style: AppTextStyles.title15TextSecondary),
          SizedBox(width: 0.01 * w),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 0.018 * h,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
