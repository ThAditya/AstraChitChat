import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';

class StorageManagementScreen extends StatelessWidget {
  const StorageManagementScreen({super.key});

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
          'Storage',
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
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStorageOverview(),
                SizedBox(height: 32.h),
                _buildSectionHeader('MEDIA STORAGE'),
                _buildStorageItem(Iconsax.video_play_copy, 'Videos', '1.2 GB', 0.6),
                _buildStorageItem(Iconsax.image_copy, 'Images', '450 MB', 0.25),
                _buildStorageItem(Iconsax.music_copy, 'Audio', '120 MB', 0.1),
                _buildStorageItem(Iconsax.document_copy, 'Documents', '32 MB', 0.05),
                SizedBox(height: 32.h),
                _buildSectionHeader('ACTIONS'),
                _buildActionTile(Iconsax.trash_copy, 'Clear Cache', 'Free up 128 MB', Colors.white),
                _buildActionTile(Iconsax.refresh_copy, 'Reset Media Settings', 'Restore defaults', Colors.white),
                _buildActionTile(Iconsax.info_circle_copy, 'Deep Clean', 'Find large files', AppColors.primaryNeon),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNeon,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildStorageOverview() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Used Space', style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 12.sp)),
                  Text('1.8 GB', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Free Space', style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 12.sp)),
                  Text('14.2 GB', style: GoogleFonts.orbitron(color: AppColors.secondaryNeon, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: 0.12,
              minHeight: 8.h,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: AppColors.primaryNeon,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildStorageItem(IconData icon, String title, String size, double progress) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20.sp),
              SizedBox(width: 12.w),
              Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp)),
              const Spacer(),
              Text(size, style: GoogleFonts.inter(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4.h,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20.sp),
        title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 11.sp)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12.sp),
        onTap: () {},
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
