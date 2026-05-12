import 'package:ai_diet_coach/core/components/custom_elevated_button.dart';
import 'package:ai_diet_coach/core/components/custom_text_form_field.dart';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/app_route/route_names.dart';
import 'package:ai_diet_coach/features/auth/sign_in/view_models/cubit/sign_in_cubit.dart';
import 'package:ai_diet_coach/features/auth/sign_in/view_models/cubit/sign_in_state.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInCubit(),
      child: const SignInScreenContent(),
    );
  }
}

class SignInScreenContent extends StatefulWidget {
  const SignInScreenContent({super.key});

  @override
  State<SignInScreenContent> createState() => _SignInScreenContentState();
}

class _SignInScreenContentState extends State<SignInScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<SignInCubit>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;

    return BlocListener<SignInCubit, SignInState>(
      listener: (context, state) {
        if (state is SignInLoading) {
          CustomQuickAlert.loading();
        } else if (state is SignInSuccess) {
          Navigator.pop(context); // Close loading
          Navigator.pushReplacementNamed(context, RouteNames.dashboardScreen);
        } else if (state is SignInFailure) {
          Navigator.pop(context); // Close loading
          CustomQuickAlert.error(
            title: 'Sign In Failed',
            message: state.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -0.09 * h,
                right: -0.08 * w,
                child: _AuthBlurCircle(
                  size: 0.24 * h,
                  color: AppColors.primaryLight.withOpacity(0.5),
                ),
              ),
              Positioned(
                bottom: -0.12 * h,
                left: -0.1 * w,
                child: _AuthBlurCircle(
                  size: 0.26 * h,
                  color: AppColors.secondaryLight.withOpacity(0.35),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 0.06 * w,
                  vertical: 0.02 * h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AiBadge(),
                    SizedBox(height: 0.028 * h),
                    Text(
                      'Welcome back 👋',
                      style: AppTextStyles.title28BlackW700,
                    ),
                    SizedBox(height: 0.006 * h),
                    Text(
                      'Stay on track with your nutrition, workouts, and health data.',
                      style: AppTextStyles.title15TextSecondary,
                    ),
                    SizedBox(height: 0.016 * h),
                    const _FeatureChipsRow(),
                    SizedBox(height: 0.03 * h),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AuthCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email address',
                                      style: AppTextStyles.title16PrimaryGreenW600,
                                    ),
                                    SizedBox(height: 0.008 * h),
                                    CustomTextFormField(
                                      controller: _emailController,
                                      hintText: 'you@example.com',
                                      prefixIcon: Icons.email_rounded,
                                      validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                                    ),
                                    SizedBox(height: 0.025 * h),
                                    Text(
                                      'Password',
                                      style: AppTextStyles.title16PrimaryGreenW600,
                                    ),
                                    SizedBox(height: 0.008 * h),
                                    CustomTextFormField(
                                      controller: _passwordController,
                                      hintText: 'Your secure password',
                                      prefixIcon: Icons.lock_rounded,
                                      obscureText: _obscurePassword,
                                      validator: (v) => v!.isEmpty ? 'Password is required' : null,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    SizedBox(height: 0.01 * h),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          'Forgot password?',
                                          style: AppTextStyles.title14PrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 0.03 * h),
                              CustomElevatedButton(
                                name: 'Sign in',
                                width: double.infinity,
                                hPadding: 0.017 * h,
                                wPadding: 0,
                                onPressed: _onSignIn,
                                backgroundColor: AppColors.primary,
                                forgroundColor: Colors.white,
                                textStyle: AppTextStyles.title18WhiteW600,
                              ),
                              SizedBox(height: 0.02 * h),
                              _buildSocialRow(w),
                              SizedBox(height: 0.03 * h),
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, RouteNames.signUpScreen),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Don't have an account? ",
                                      style: AppTextStyles.title15TextSecondary,
                                      children: [
                                        TextSpan(text: 'Sign up', style: AppTextStyles.title15GreenW600),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 0.02 * h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialRow(double w) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.02 * w),
              child: Text('or continue with', style: AppTextStyles.title12BlackColor54),
            ),
            Expanded(child: Container(height: 1, color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _SocialCircleIcon(icon: Icons.g_mobiledata_rounded),
            SizedBox(width: 0.025 * w),
            const _SocialCircleIcon(icon: Icons.apple_rounded),
          ],
        ),
      ],
    );
  }
}

class _AuthBlurCircle extends StatelessWidget {
  const _AuthBlurCircle({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}

class _AiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.03 * w, vertical: 0.007 * h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [AppColors.aiGradientStart, AppColors.aiGradientEnd]),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.smart_toy_rounded, color: Colors.white, size: 0.022 * h),
          SizedBox(width: 0.012 * w),
          Text('AI Diet Coach', style: AppTextStyles.label13WhiteW600),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.height * 0.022),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.7), blurRadius: 30, offset: const Offset(0, 16))],
      ),
      child: child,
    );
  }
}

class _SocialCircleIcon extends StatelessWidget {
  const _SocialCircleIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    return Container(
      width: 0.06 * h,
      height: 0.06 * h,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.7), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Icon(icon, color: AppColors.textPrimary, size: 0.03 * h),
    );
  }
}

class _FeatureChipsRow extends StatelessWidget {
  const _FeatureChipsRow();
  @override
  Widget build(BuildContext context) {
    final double w = SizeConfig.width;
    return Row(
      children: [
        const _SmallChip(icon: Icons.restaurant_rounded, label: 'Nutrition', color: AppColors.primary),
        SizedBox(width: 0.02 * w),
        const _SmallChip(icon: Icons.fitness_center_rounded, label: 'Workout', color: AppColors.secondary),
        SizedBox(width: 0.02 * w),
        const _SmallChip(icon: Icons.monitor_heart_rounded, label: 'Tracking', color: AppColors.accent),
      ],
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.022 * w, vertical: 0.005 * h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.95),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 0.018 * h, color: color),
          SizedBox(width: 0.008 * w),
          Text(label, style: AppTextStyles.title12BlackColor54),
        ],
      ),
    );
  }
}
