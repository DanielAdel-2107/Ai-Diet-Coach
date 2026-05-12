import 'package:ai_diet_coach/core/network/supabase/auth/sign_up_with_password.dart';
import 'package:ai_diet_coach/core/network/supabase/database/add_data.dart';
import 'package:ai_diet_coach/features/auth/sign_up/models/user_model.dart';
import 'package:ai_diet_coach/features/auth/sign_up/view_models/sign_up_cubit/sign_up_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diet_coach/core/di/dependancy_injection.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String gender,
    required int age,
    required double height,
    required double weight,
    required String goal,
    required bool agreeToTerms,
  }) async {
    if (!agreeToTerms) {
      emit(
        SignUpFailure(
          "Please agree to the Terms of Service and Privacy Policy",
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      emit(SignUpFailure("Passwords do not match"));
      return;
    }

    emit(SignUpLoading());

    try {
      // 1. Auth Sign Up
      await signUpWithPassword(email: email, password: password);

      final user = getIt<SupabaseClient>().auth.currentUser;
      if (user == null) {
        emit(SignUpFailure("User registration failed. Please try again."));
        return;
      }

      // 2. Create User Profile
      final userModel = UserModel(
        id: user.id,
        name: name,
        email: email,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        goal: goal,
        bmi: _calculateBMI(weight, height),
      );

      await addData(
        tableName: 'user_profiles',
        data: {
          'id': user.id,
          'name': name,
          'email': email,
          'gender': gender,
          'age': age,
          'height': height,
          'weight': weight,
          'goal': goal,
          'bmi': _calculateBMI(weight, height),
        },
      );

      emit(SignUpSuccess());
    } catch (e) {
      emit(SignUpFailure(e.toString()));
    }
  }

  double _calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    double heightInMeters = height / 100;
    return double.parse(
      (weight / (heightInMeters * heightInMeters)).toStringAsFixed(1),
    );
  }
}
