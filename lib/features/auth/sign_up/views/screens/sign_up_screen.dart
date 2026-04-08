import 'package:ai_diet_coach/core/components/custom_elevated_button.dart';
import 'package:ai_diet_coach/core/components/custom_text_form_field.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/core/app_route/route_names.dart';
import 'package:ai_diet_coach/features/auth/sign_up/view_models/sign_up_cubit/sign_up_cubit.dart';
import 'package:ai_diet_coach/features/auth/sign_up/view_models/sign_up_cubit/sign_up_state.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(),
      child: const SignUpScreenContent(),
    );
  }
}

class SignUpScreenContent extends StatefulWidget {
  const SignUpScreenContent({super.key});

  @override
  State<SignUpScreenContent> createState() => _SignUpScreenContentState();
}

class _SignUpScreenContentState extends State<SignUpScreenContent> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedGoal = 'Lose weight';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        CustomQuickAlert.error(
          title: 'Terms of Service',
          message: 'Please agree to the terms and conditions.',
        );
        return;
      }
      context.read<SignUpCubit>().signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        gender: _selectedGender,
        age: int.tryParse(_ageController.text) ?? 25,
        height: double.tryParse(_heightController.text) ?? 170.0,
        weight: double.tryParse(_weightController.text) ?? 70.0,
        goal: _selectedGoal,
        agreeToTerms: _agreeToTerms,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;

    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpLoading) {
          CustomQuickAlert.loading();
        } else if (state is SignUpSuccess) {
          Navigator.pop(context); // Close loading
          Navigator.pop(context); // Close loading
          CustomQuickAlert.success(
            title: 'Success',
            message: 'Account created successfully!',
          );
        } else if (state is SignUpFailure) {
          Navigator.pop(context); // Close loading
          CustomQuickAlert.error(
            title: 'Registration Failed',
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
                top: -0.1 * h,
                right: -0.09 * w,
                child: _AuthBlurCircle(
                  size: 0.26 * h,
                  color: AppColors.primaryLight.withOpacity(0.5),
                ),
              ),
              Positioned(
                bottom: -0.13 * h,
                left: -0.1 * w,
                child: _AuthBlurCircle(
                  size: 0.28 * h,
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
                    SizedBox(height: 0.024 * h),
                    Text(
                      'Create your account',
                      style: AppTextStyles.title28BlackW700,
                    ),
                    SizedBox(height: 0.006 * h),
                    Text(
                      'Join your AI Diet Coach and start a smarter health journey.',
                      style: AppTextStyles.title15TextSecondary,
                    ),
                    SizedBox(height: 0.018 * h),
                    _GoalChipsRow(
                      selectedGoal: _selectedGoal,
                      onGoalSelected: (goal) =>
                          setState(() => _selectedGoal = goal),
                    ),
                    SizedBox(height: 0.028 * h),
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
                                    _buildFieldLabel('Full name'),
                                    CustomTextFormField(
                                      controller: _nameController,
                                      hintText: 'Your full name',
                                      prefixIcon: Icons.person_rounded,
                                      validator: (v) => v!.isEmpty
                                          ? 'Name is required'
                                          : null,
                                    ),
                                    SizedBox(height: 0.02 * h),
                                    _buildFieldLabel('Email address'),
                                    CustomTextFormField(
                                      controller: _emailController,
                                      hintText: 'you@example.com',
                                      prefixIcon: Icons.email_rounded,
                                      validator: (v) => !v!.contains('@')
                                          ? 'Invalid email'
                                          : null,
                                    ),
                                    SizedBox(height: 0.02 * h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildFieldLabel('Age'),
                                              CustomTextFormField(
                                                controller: _ageController,
                                                hintText: '25',
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (v) => v!.isEmpty
                                                    ? 'Required'
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 0.03 * w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildFieldLabel('Height (cm)'),
                                              CustomTextFormField(
                                                controller: _heightController,
                                                hintText: '170',
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (v) => v!.isEmpty
                                                    ? 'Required'
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 0.03 * w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildFieldLabel('Weight (kg)'),
                                              CustomTextFormField(
                                                controller: _weightController,
                                                hintText: '70',
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (v) => v!.isEmpty
                                                    ? 'Required'
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.02 * h),
                                    _buildFieldLabel('Gender'),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.scaffoldBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedGender,
                                          isExpanded: true,
                                          items: ['Male', 'Female'].map((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style:
                                                    AppTextStyles.title14Black,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) => setState(
                                            () => _selectedGender = val!,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 0.02 * h),
                                    _buildFieldLabel('Password'),
                                    CustomTextFormField(
                                      controller: _passwordController,
                                      hintText: 'Create a strong password',
                                      prefixIcon: Icons.lock_rounded,
                                      obscureText: _obscurePassword,
                                      validator: (v) => v!.length < 6
                                          ? 'Min 6 characters'
                                          : null,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 0.02 * h),
                                    _buildFieldLabel('Confirm password'),
                                    CustomTextFormField(
                                      controller: _confirmPasswordController,
                                      hintText: 'Repeat your password',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      obscureText: _obscureConfirmPassword,
                                      validator: (v) =>
                                          v != _passwordController.text
                                          ? 'Passwords do not match'
                                          : null,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureConfirmPassword =
                                              !_obscureConfirmPassword,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 0.016 * h),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 0.05 * w,
                                          child: Checkbox(
                                            value: _agreeToTerms,
                                            activeColor: AppColors.primary,
                                            onChanged: (val) => setState(
                                              () =>
                                                  _agreeToTerms = val ?? false,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 0.01 * w),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'I agree to the ',
                                              style: AppTextStyles
                                                  .title12BlackColor54,
                                              children: [
                                                TextSpan(
                                                  text: 'Terms of Service ',
                                                  style: AppTextStyles
                                                      .title12PrimaryColorW500,
                                                ),
                                                const TextSpan(text: 'and '),
                                                TextSpan(
                                                  text: 'Privacy Policy',
                                                  style: AppTextStyles
                                                      .title12PrimaryColorW500,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 0.03 * h),
                              CustomElevatedButton(
                                name: 'Create account',
                                width: double.infinity,
                                hPadding: 0.017 * h,
                                wPadding: 0,
                                onPressed: _onSignUp,
                                backgroundColor: AppColors.primary,
                                forgroundColor: Colors.white,
                                textStyle: AppTextStyles.title18WhiteW600,
                              ),
                              SizedBox(height: 0.02 * h),
                              _buildSocialRow(w),
                              SizedBox(height: 0.03 * h),
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushReplacementNamed(
                                    context,
                                    RouteNames.signInScreen,
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Already have an account? ',
                                      style: AppTextStyles.title15TextSecondary,
                                      children: [
                                        TextSpan(
                                          text: 'Sign in',
                                          style: AppTextStyles.title15GreenW600,
                                        ),
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: AppTextStyles.title16PrimaryGreenW600),
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
              child: Text(
                'or continue with',
                style: AppTextStyles.title12BlackColor54,
              ),
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
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
        gradient: const LinearGradient(
          colors: [AppColors.aiGradientStart, AppColors.aiGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
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
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withOpacity(0.7),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.textPrimary, size: 0.03 * h),
    );
  }
}

class _GoalChipsRow extends StatelessWidget {
  final String selectedGoal;
  final Function(String) onGoalSelected;
  const _GoalChipsRow({
    required this.selectedGoal,
    required this.onGoalSelected,
  });
  @override
  Widget build(BuildContext context) {
    final double w = SizeConfig.width;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _GoalChip(
            icon: Icons.trending_down_rounded,
            label: 'Lose weight',
            color: AppColors.primary,
            isSelected: selectedGoal == 'Lose weight',
            onTap: () => onGoalSelected('Lose weight'),
          ),
          SizedBox(width: 0.02 * w),
          _GoalChip(
            icon: Icons.trending_up_rounded,
            label: 'Gain muscle',
            color: AppColors.secondary,
            isSelected: selectedGoal == 'Gain muscle',
            onTap: () => onGoalSelected('Gain muscle'),
          ),
          SizedBox(width: 0.02 * w),
          _GoalChip(
            icon: Icons.favorite_rounded,
            label: 'Healthy lifestyle',
            color: AppColors.accent,
            isSelected: selectedGoal == 'Healthy lifestyle',
            onTap: () => onGoalSelected('Healthy lifestyle'),
          ),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final double h = SizeConfig.height;
    final double w = SizeConfig.width;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: 0.028 * w,
          vertical: 0.007 * h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected ? color : Colors.white.withOpacity(0.96),
          border: Border.all(color: color.withOpacity(0.35)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 0.02 * h,
              color: isSelected ? Colors.white : color,
            ),
            SizedBox(width: 0.01 * w),
            Text(
              label,
              style: AppTextStyles.title12BlackColor54.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
