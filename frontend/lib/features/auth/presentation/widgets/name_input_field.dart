import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class NameInputField extends StatelessWidget {
  final TextEditingController controller;

  const NameInputField({super.key, required this.controller});

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
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        style: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Full Name",
          hintStyle: GoogleFonts.inter(
            color: AppColors.textGrey,
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            Iconsax.user_copy,
            color: AppColors.primaryNeon.withOpacity(0.5),
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}
