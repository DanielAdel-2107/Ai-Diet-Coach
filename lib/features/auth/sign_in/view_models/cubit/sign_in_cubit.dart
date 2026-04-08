import 'package:ai_diet_coach/core/network/supabase/auth/sign_in_with_password.dart';
import 'package:ai_diet_coach/features/auth/sign_in/view_models/cubit/sign_in_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(SignInInitial());

  Future<void> signIn({required String email, required String password}) async {
    emit(SignInLoading());
    try {
      await signInWithPassword(email: email, password: password);
      emit(SignInSuccess());
    } catch (e) {
      emit(SignInFailure(error: e.toString()));
    }
  }
}
