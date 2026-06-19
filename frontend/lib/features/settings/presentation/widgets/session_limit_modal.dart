import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:chitchat/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';

class SessionLimitModal extends StatelessWidget {
  const SessionLimitModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SessionLimitModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 500.h,
      borderRadius: 32.r,
      blur: 30,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1A1A1A).withValues(alpha: 0.9),
          const Color(0xFF0D0D0D).withValues(alpha: 0.95),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 32.h),
            
            // Icon
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.mobile_copy, color: AppColors.warning, size: 40.sp),
            ),
            SizedBox(height: 24.h),
            
            Text(
              'Mobile Device Limit Reached',
              style: GoogleFonts.orbitron(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Your current plan allows only 1 active mobile device. Upgrade to Premium to use Chit Chat on up to 3 mobile devices simultaneously.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            
            // Buttons
            _buildButton(
              'Upgrade to Premium',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.premium);
              },
              isPrimary: true,
            ),
            SizedBox(height: 12.h),
            _buildButton(
              'Continue & Logout Previous Device',
              onTap: () {
                Navigator.pop(context);
                // Handle session transfer logic
              },
              isPrimary: false,
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, {required VoidCallback onTap, required bool isPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          gradient: isPrimary ? const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
          ) : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: isPrimary ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
