import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          'About',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppColors.primaryNeon.withOpacity(0.3)),
                  ),
                  child: Icon(Iconsax.flash_1_copy, color: AppColors.primaryNeon, size: 50.sp),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                SizedBox(height: 24.h),
                Text(
                  'CHIT CHAT',
                  style: GoogleFonts.orbitron(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  'Version 1.0.4',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                  ),
                ),
                SizedBox(height: 48.h),
                _buildInfoSection('The Future of Connection', 'Chit Chat is a next-generation social platform designed for privacy, speed, and creative expression. Built with cutting-edge technology to keep you connected with the world.'),
                SizedBox(height: 32.h),
                _buildInfoSection('Our Mission', 'To bridge the gap between human connection and digital privacy, providing a seamless experience for creators and friends alike.'),
                SizedBox(height: 48.h),
                Divider(color: Colors.white.withOpacity(0.05)),
                SizedBox(height: 24.h),
                Text(
                  'Developed by\nCHIT CHAT LABS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 12.sp,
                    color: AppColors.primaryNeon,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textGrey,
            height: 1.6,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
