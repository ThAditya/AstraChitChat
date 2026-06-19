import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:chitchat/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/features/settings/presentation/widgets/session_limit_modal.dart';
import 'package:chitchat/features/stories/presentation/screens/close_friends_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _readReceipts = true;
  bool _typingIndicator = true;
  bool _screenshotAlerts = true;
  bool _twoStepVerification = false;

  @override
  Widget build(BuildContext context) {
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
          'Privacy & Security',
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
                _buildSecurityDashboard(),
                SizedBox(height: 24.h),
                _buildPremiumMultiDeviceCard(),
                SizedBox(height: 24.h),
                _buildSectionHeader('CYBER PROTECTION'),
                _buildEncryptionCard(),
                SizedBox(height: 24.h),
                _buildSectionHeader('PRIVACY CONTROLS'),
                _buildPrivacyGroup(),
                SizedBox(height: 24.h),
                _buildSectionHeader('SECURITY PROTOCOLS'),
                _buildSecurityGroup(),
                SizedBox(height: 24.h),
                _buildSectionHeader('ACTIVE SESSIONS'),
                _buildDevicesGroup(),
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

  Widget _buildSecurityDashboard() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 180.h,
      borderRadius: 24.r,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
      ),
      borderGradient: LinearGradient(
        colors: [AppColors.primaryNeon.withOpacity(0.5), Colors.transparent],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Row(
          children: [
            // Circular Score
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100.r,
                  height: 100.r,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 8.r,
                    color: AppColors.primaryNeon,
                    backgroundColor: Colors.white.withOpacity(0.05),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '85%',
                      style: GoogleFonts.orbitron(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'SECURE',
                      style: GoogleFonts.inter(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNeon,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 24.w),
            // Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Status',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildStatusRow(Iconsax.shield_tick_copy, 'E2EE Active', AppColors.success),
                  SizedBox(height: 6.h),
                  _buildStatusRow(Iconsax.mobile_copy, '2 Devices Protected', Colors.white70),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'UPGRADE PROTECTION',
                      style: GoogleFonts.orbitron(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNeon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(delay: 100.ms);
  }

  Widget _buildPremiumMultiDeviceCard() {
    return GestureDetector(
      onTap: () => context.push(AppRouter.premium),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 110.h,
        borderRadius: 24.r,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.15),
            const Color(0xFFA855F7).withValues(alpha: 0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.5),
            const Color(0xFFA855F7).withValues(alpha: 0.2),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.crown_1_copy, color: const Color(0xFF818CF8), size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Multi-Device Access',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Use Chit Chat on up to 3 mobile devices simultaneously.',
                      style: GoogleFonts.inter(
                        color: AppColors.textGrey,
                        fontSize: 11.sp,
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
    ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildStatusRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 8.w),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 12.sp, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildEncryptionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.secondaryNeon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.secondaryNeon.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.lock_copy, color: AppColors.secondaryNeon, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'End-to-End Encryption',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Chit Chat ensures that only you and the person you’re communicating with can read or listen to what is sent. Not even Chit Chat can access your data.',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPrivacyGroup() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildMenuTile(Iconsax.profile_circle_copy, 'Profile Photo', 'My Contacts'),
          _buildMenuTile(Iconsax.eye_copy, 'Last Seen & Online', 'Nobody'),
          _buildMenuTile(Iconsax.heart_copy, 'Close Friends', '2 people', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CloseFriendsScreen()))),
          _buildToggleTile(Iconsax.tick_circle_copy, 'Read Receipts', _readReceipts, (v) => setState(() => _readReceipts = v)),
          _buildToggleTile(Iconsax.text_italic_copy, 'Typing Indicator', _typingIndicator, (v) => setState(() => _typingIndicator = v)),
          _buildToggleTile(Iconsax.camera_copy, 'Screenshot Alerts', _screenshotAlerts, (v) => setState(() => _screenshotAlerts = v)),
          _buildMenuTile(Iconsax.call_copy, 'Who can call me', 'Everyone'),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSecurityGroup() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildToggleTile(Iconsax.password_check_copy, 'Two-Step Verification', _twoStepVerification, (v) => setState(() => _twoStepVerification = v)),
          _buildMenuTile(Iconsax.key_copy, 'Change Security PIN', null),
          _buildMenuTile(Iconsax.user_minus_copy, 'Blocked Users', '12 users'),
          _buildMenuTile(Iconsax.recovery_convert_copy, 'Account Recovery', null),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDevicesGroup() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildDeviceItem('iPhone 15 Pro', 'Current Device • London, UK', true),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 24.h),
          _buildDeviceItem('Windows 11 • Chrome', 'Active 2h ago • Paris, FR', false),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => context.push(AppRouter.deviceManagement),
                child: Text(
                  'MANAGE DEVICES',
                  style: GoogleFonts.orbitron(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNeon,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => SessionLimitModal.show(context),
                child: Text(
                  'LOGOUT ALL OTHERS',
                  style: GoogleFonts.orbitron(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDeviceItem(String name, String desc, bool isCurrent) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.primaryNeon.withOpacity(0.1) : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCurrent ? Iconsax.mobile_copy : Iconsax.monitor_copy,
            color: isCurrent ? AppColors.primaryNeon : Colors.white70,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
        if (!isCurrent)
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.logout_copy, color: AppColors.error, size: 18.sp),
          ),
      ],
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String? subtitle, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white, size: 20.sp),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null)
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.primaryNeon),
            ),
          SizedBox(width: 8.w),
          Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 12.sp),
        ],
      ),
    );
  }

  Widget _buildToggleTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 20.sp),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryNeon,
        activeTrackColor: AppColors.primaryNeon.withOpacity(0.2),
        inactiveThumbColor: AppColors.textGrey,
        inactiveTrackColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
