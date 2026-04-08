import 'package:flutter/material.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/views/widgets/sugar_tracking_body.dart';

class SugarTrackingScreen extends StatelessWidget {
  const SugarTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SugarTrackingBody(),
    );
  }
}
