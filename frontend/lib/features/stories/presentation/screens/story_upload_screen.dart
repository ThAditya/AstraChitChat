import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:glassmorphism/glassmorphism.dart';

class StoryUploadScreen extends StatefulWidget {
  const StoryUploadScreen({super.key});

  @override
  State<StoryUploadScreen> createState() => _StoryUploadScreenState();
}

class _StoryUploadScreenState extends State<StoryUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background - Mock Camera View
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF121212),
            child: Center(
              child: Icon(Iconsax.camera_copy, size: 80.sp, color: Colors.white10),
            ),
          ),

          // Top Controls
          Positioned(
            top: 60.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(Icons.close, onTap: () => Navigator.pop(context)),
                Row(
                  children: [
                    _buildCircularButton(Iconsax.flash_1_copy),
                    SizedBox(width: 16.w),
                    _buildCircularButton(Iconsax.setting_2_copy),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeText("TEXT"),
                    SizedBox(width: 24.w),
                    _buildModeText("CAMERA", isActive: true),
                    SizedBox(width: 24.w),
                    _buildModeText("VIDEO"),
                  ],
                ),
                SizedBox(height: 32.h),
                // Main Capture Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGalleryPreview(),
                      _buildCaptureButton(),
                      _buildFlipCameraButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Side Tools
          Positioned(
            right: 20.w,
            top: 200.h,
            child: Column(
              children: [
                _buildToolItem(Iconsax.music_copy, "Music"),
                _buildToolItem(Iconsax.magicpen_copy, "Effects"),
                _buildToolItem(Iconsax.link_copy, "Link"),
                _buildToolItem(Iconsax.emoji_happy_copy, "Stickers"),
                _buildToolItem(Iconsax.security_safe_copy, "Privacy", onTap: () => _showPrivacySheet(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 480.h,
        borderRadius: 30.r,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.9)],
        ),
        borderGradient: LinearGradient(
          colors: [AppColors.primaryNeon.withOpacity(0.5), Colors.transparent],
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Story Privacy",
                style: GoogleFonts.orbitron(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Choose who can see your story.",
                style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textGrey),
              ),
              SizedBox(height: 24.h),
              _buildPrivacyOption(Iconsax.global_copy, "Public", "Anyone on Chit Chat", true),
              _buildPrivacyOption(Iconsax.user_copy, "Followers Only", "People you follow back", false),
              _buildPrivacyOption(Iconsax.heart_copy, "Close Friends", "Your selected circle", false, isGreen: true),
              _buildPrivacyOption(Iconsax.profile_2user_copy, "Custom", "Select specific people", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(IconData icon, String title, String subtitle, bool isSelected, {bool isGreen = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryNeon.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? AppColors.primaryNeon : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isGreen ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isGreen ? Colors.green : Colors.white70, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: AppColors.primaryNeon, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildModeText(String text, {bool isActive = false}) {
    return Text(
      text,
      style: GoogleFonts.orbitron(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: isActive ? AppColors.primaryNeon : Colors.white60,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildGalleryPreview() {
    return Container(
      width: 45.r,
      height: 45.r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white, width: 2),
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/200'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Container(
      width: 80.r,
      height: 80.r,
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildFlipCameraButton() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Iconsax.rotate_right_copy, color: Colors.white, size: 24.sp),
    );
  }

  Widget _buildToolItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
