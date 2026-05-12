import 'dart:async';

import 'package:ai_diet_coach/core/utils/assets/images/app_images.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/app_route/route_names.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        Navigator.pushReplacementNamed(context, RouteNames.dashboardScreen);
      } else if (onboardingSeen) {
        Navigator.pushReplacementNamed(context, RouteNames.signInScreen);
      } else {
        Navigator.pushReplacementNamed(context, RouteNames.onBoardingScreen);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight.withOpacity(0.08),
              AppColors.scaffoldBackground,
            ],
          ),
        ),
        child: Stack(
          children: [
            // softened background circles with lower opacity
            Positioned(
              top: -0.1 * h,
              right: -0.15 * w,
              child: _SplashBlurCircle(
                size: 0.35 * h,
                color: AppColors.primaryLight.withOpacity(0.3),
              ),
            ),
            Positioned(
              bottom: -0.15 * h,
              left: -0.18 * w,
              child: _SplashBlurCircle(
                size: 0.4 * h,
                color: AppColors.secondaryLight.withOpacity(0.25),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 0.06 * w,
                  vertical: 0.03 * h,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0.025 * w,
                            vertical: 0.006 * h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.85),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 0.018 * h,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 0.01 * w),
                              Text(
                                'AI Diet Coach',
                                style: AppTextStyles.title12BlackColor54,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0.02 * w,
                            vertical: 0.004 * h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black.withOpacity(0.04),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent,
                                ),
                              ),
                              SizedBox(width: 0.008 * w),
                              Text(
                                'Loading',
                                style: AppTextStyles.title12BlackColor54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.1 * h),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _LogoImage(),
                          ),
                          SizedBox(height: 0.05 * h),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Your smart health coach',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.title24PrimaryW700,
                                ),
                                SizedBox(height: 0.01 * h),
                                Text(
                                  'AI-powered nutrition, workouts, and tracking\npersonalized just for you.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.title15TextSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0.04 * h),
                    _LoadingBar(),
                    SizedBox(height: 0.012 * h),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Getting things ready for you...',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title12BlackColor54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBlurCircle extends StatelessWidget {
  const _SplashBlurCircle({required this.size, required this.color});

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

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;

    return Container(
      width: 0.24 * h,
      height: 0.24 * h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(0.032 * w),
      child: Image.asset(AppImages.logoImage, fit: BoxFit.contain),
    );
  }
}

class _LogoImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;

    return SizedBox(
      width: 0.24 * h,
      height: 0.24 * h,
      child: _LogoMark(),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double w = SizeConfig.width;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 0.5 * w,
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppColors.border.withOpacity(0.2),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.7),
                          AppColors.secondary.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
