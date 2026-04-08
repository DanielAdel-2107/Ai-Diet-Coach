import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:flutter/material.dart';

extension AppExtensions on BuildContext {
  // navigation
  void pushScreen(String routeName, {Object? arguments}) {
    Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  void pushReplacementScreen(String routeName, {Object? arguments}) {
    Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }

  void pushAndRemoveUntilScreen(String routeName) {
    Navigator.of(this).pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  void popScreen() {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }

  void popWithResult<T>(T result) {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop(result);
    }
  }

  bool canPopScreen() {
    return Navigator.of(this).canPop();
  }
}

extension SizeConfigExtension on num {
  double get w => this * SizeConfig.width / 100;
  double get h => this * SizeConfig.height / 100;
  double get sp => this * SizeConfig.width / 375;
  double get r => this * SizeConfig.width / 375;
}
