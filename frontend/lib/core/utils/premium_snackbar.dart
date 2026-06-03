import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../theme/app_colors.dart';

class PremiumSnackBar {
  static void show(
    BuildContext context, 
    String message, {
    IconData? icon, 
    Color? color,
    Duration duration = const Duration(seconds: 3),
  }) {
    final effectiveColor = color ?? AppColors.primaryNeon;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
        duration: duration,
        content: GlassmorphicContainer(
          width: double.infinity,
          height: 60.h,
          borderRadius: 16.r,
          blur: 20,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              effectiveColor.withValues(alpha: 0.15),
              effectiveColor.withValues(alpha: 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              effectiveColor.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: effectiveColor, size: 22.sp),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
