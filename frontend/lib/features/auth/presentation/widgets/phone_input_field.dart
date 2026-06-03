import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          // Country Picker Placeholder
          GestureDetector(
            onTap: () {
              // Show country picker
            },
            child: Row(
              children: [
                Text(
                  "🇮🇳",
                  style: TextStyle(fontSize: 24.sp),
                ),
                SizedBox(width: 8.w),
                Text(
                  "+91",
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textGrey,
                  size: 20.sp,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            height: 30.h,
            width: 1.w,
            color: Colors.white.withOpacity(0.1),
          ),
          SizedBox(width: 12.w),
          // Input Field
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Phone Number",
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textGrey,
                  fontSize: 16.sp,
                  letterSpacing: 0,
                ),
                suffixIcon: Icon(
                  Iconsax.mobile_copy,
                  color: AppColors.primaryNeon.withOpacity(0.5),
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
