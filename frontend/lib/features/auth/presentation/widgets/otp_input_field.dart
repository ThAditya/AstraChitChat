import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/app_colors.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50.w,
      height: 60.h,
      textStyle: GoogleFonts.inter(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: AppColors.primaryNeon,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNeon.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primaryNeon.withOpacity(0.05),
        border: Border.all(
          color: AppColors.primaryNeon.withOpacity(0.5),
        ),
      ),
    );

    return Pinput(
      length: 6,
      controller: controller,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      onCompleted: onCompleted,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      cursor: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            width: 20.w,
            height: 2.h,
            color: AppColors.primaryNeon,
          ),
        ],
      ),
    );
  }
}
