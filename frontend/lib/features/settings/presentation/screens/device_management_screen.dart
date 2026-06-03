import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:chitchat/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';

class DeviceManagementScreen extends StatefulWidget {
  final bool isPremium;
  const DeviceManagementScreen({super.key, this.isPremium = false});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  @override
  Widget build(BuildContext context) {
    int maxDevices = widget.isPremium ? 3 : 1;
    int currentDevices = 1; // Mock current count

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          'Device Management',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
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
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                _buildUsageProgress(currentDevices, maxDevices),
                SizedBox(height: 32.h),
                _buildSectionHeader('MOBILE DEVICES'),
                _buildMobileDevicesList(),
                SizedBox(height: 32.h),
                _buildSectionHeader('WEB SESSIONS'),
                _buildWebSessionsList(),
                if (!widget.isPremium) ...[
                  SizedBox(height: 32.h),
                  _buildPremiumUpsellCard(),
                ],
                SizedBox(height: 40.h),
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
          color: AppColors.primaryNeon.withOpacity(0.8),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildUsageProgress(int current, int max) {
    double progress = current / max;
    return GlassmorphicContainer(
      width: double.infinity,
      height: 140.h,
      borderRadius: 24.r,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
      ),
      borderGradient: LinearGradient(
        colors: [AppColors.primaryNeon.withValues(alpha: 0.5), Colors.transparent],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mobile Devices Used',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$current / $max',
                  style: GoogleFonts.orbitron(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNeon,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12.h,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? AppColors.warning : AppColors.primaryNeon,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              widget.isPremium 
                ? 'You can add ${max - current} more mobile devices.'
                : 'Free plan limit: 1 mobile device. Unlimited web sessions.',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildMobileDevicesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildDeviceTile(
            'iPhone 15 Pro',
            'Current Device • London, UK',
            Iconsax.mobile_copy,
            true,
          ),
          if (widget.isPremium) ...[
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            _buildDeviceTile(
              'iPad Pro 12.9',
              'Active 5m ago • London, UK',
              Iconsax.mobile_copy,
              false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWebSessionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildDeviceTile(
            'Windows 11 • Chrome',
            'Active now • Paris, FR',
            Iconsax.monitor_copy,
            false,
            isWeb: true,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          _buildDeviceTile(
            'MacBook Air • Safari',
            'Active 2 days ago • Berlin, DE',
            Iconsax.monitor_copy,
            false,
            isWeb: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(String name, String desc, IconData icon, bool isCurrent, {bool isWeb = false}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.primaryNeon.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isCurrent ? AppColors.primaryNeon : Colors.white70,
          size: 20.sp,
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        desc,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: AppColors.textGrey,
        ),
      ),
      trailing: !isCurrent ? IconButton(
        onPressed: () {},
        icon: Icon(Iconsax.logout_copy, color: AppColors.error, size: 20.sp),
      ) : Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.primaryNeon.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          'THIS DEVICE',
          style: GoogleFonts.inter(
            fontSize: 8.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNeon,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumUpsellCard() {
    return GestureDetector(
      onTap: () => context.push(AppRouter.premium),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 100.h,
        borderRadius: 20.r,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.15),
            const Color(0xFFA855F7).withValues(alpha: 0.1),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [const Color(0xFF6366F1).withValues(alpha: 0.5), Colors.transparent],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.crown_1_copy, color: const Color(0xFF818CF8), size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Upgrade to Premium',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Use on up to 3 mobile devices simultaneously.',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white54, size: 20.sp),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
