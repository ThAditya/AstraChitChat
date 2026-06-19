import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class SecurityBanner extends StatelessWidget {
  const SecurityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryNeon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryNeon.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.lock_copy, color: AppColors.primaryNeon, size: 18.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Messages are end-to-end encrypted. No one outside of this chat, not even Chit Chat, can read them.',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
