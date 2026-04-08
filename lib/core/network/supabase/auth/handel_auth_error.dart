import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

String handleAuthError(AuthException e) {
  String errorMessage = e.message.toLowerCase();

  if (errorMessage.contains('invalid login credentials')) {
    return "The email or password is incorrect.";
  } else if (errorMessage.contains('password should be at least')) {
    return "The password is too weak. Please use a stronger password.";
  } else if (errorMessage.contains('user already registered')) {
    return "This email is already registered.";
  } else if (errorMessage.contains('network request failed')) {
    return "Please check your internet connection.";
  } else if (errorMessage.contains('email address') &&
      errorMessage.contains('invalid')) {
    return "The email address entered is invalid.";
  } else if (e.message.contains('Email not confirmed')) {
    return "Please confirm your email address.";
  } else if (errorMessage.contains('email rate limit exceeded')) {
    return "You've sent too many sign-up requests. Please wait a while before trying again.";
  }
  log(e.message);
  return e.message;
}
