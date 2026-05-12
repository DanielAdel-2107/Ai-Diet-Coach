import 'dart:ui';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

class ImmersiveBackground extends StatelessWidget {
  final Widget child;

  const ImmersiveBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Base Gradient
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.scaffoldBackground,
                AppColors.primary.withOpacity(0.05),
                AppColors.secondary.withOpacity(0.05),
                AppColors.scaffoldBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Animated Blobs
        _buildBlob(
          size,
          color: AppColors.primary.withOpacity(0.1),
          offset: const Offset(-50, 100),
          width: 250,
          height: 250,
        ),
        _buildBlob(
          size,
          color: AppColors.secondary.withOpacity(0.1),
          offset: const Offset(200, 300),
          width: 300,
          height: 300,
        ),
        _buildBlob(
          size,
          color: AppColors.accent.withOpacity(0.08),
          offset: const Offset(50, 600),
          width: 200,
          height: 200,
        ),
        // Glassmorphism Overlay (Blur)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(
            color: Colors.transparent,
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildBlob(Size size,
      {required Color color,
      required Offset offset,
      required double width,
      required double height}) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
