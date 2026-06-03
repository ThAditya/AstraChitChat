import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../../core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double height;
  final double? width;

  const GlassCard({
    super.key,
    required this.child,
    required this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: width ?? double.infinity,
      height: height,
      borderRadius: 32.r,
      blur: 25,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.03),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryNeon.withOpacity(0.3),
          AppColors.secondaryNeon.withOpacity(0.3),
        ],
      ),
      child: child,
    );
  }
}
