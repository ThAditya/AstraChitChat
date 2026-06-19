import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../../core/providers/premium_provider.dart';
import '../../../profile/domain/models/user_profile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isPushEnabled = true;
  bool _isDarkTheme = true;
  bool _isDataSaver = false;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(myProfileProvider);
    final profile = profileState.profile;
    final isPremium = ref.watch(isPremiumProvider);

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
          'Settings',
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
          if (profile == null)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                _buildProfileHeader(profile),
                SizedBox(height: 20.h),
                _buildPremiumBanner(),
                SizedBox(height: 20.h),
                _buildSettingsSection(
                  title: 'Account',
                  items: [
                    _buildSettingItem(Iconsax.user_copy, 'Edit Profile', onTap: () => context.push(AppRouter.editProfile)),
                    _buildSettingItem(Iconsax.archive_1_copy, 'Saved Library',
                        subtitle: 'Manage your saved reels, audio, and collections.',
                        onTap: () => context.push(AppRouter.savedContent)),
                    _buildSettingItem(Iconsax.call_copy, 'Change Phone Number', onTap: () => context.push('/coming-soon', extra: 'Change Phone Number')),
                    _buildSettingItem(Iconsax.language_square_copy, 'Language Settings', trailing: 'English', onTap: () => context.push(AppRouter.languageSettings)),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildSettingsSection(
                  title: 'Privacy',
                  items: [
                    _buildSettingItem(Iconsax.eye_copy, 'Last Seen control', onTap: () => context.push(AppRouter.privacySecurity)),
                    _buildSettingItem(Iconsax.security_user_copy, 'Profile Visibility', onTap: () => context.push(AppRouter.privacySecurity)),
                    _buildSettingItem(Iconsax.user_minus_copy, 'Blocked Users', onTap: () => context.push(AppRouter.privacySecurity)),
                    _buildSettingItem(Iconsax.status_copy, 'Online Status Control', onTap: () => context.push(AppRouter.privacySecurity)),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildSettingsSection(
                  title: 'Security & Devices',
                  items: [
                    _buildSettingItem(Iconsax.mobile_copy, 'Device Management', onTap: () => context.push(AppRouter.deviceManagement)),
                    _buildSettingItem(Iconsax.shield_tick_copy, 'Security Protocols', onTap: () => context.push(AppRouter.privacySecurity)),
                    _buildSettingItem(Iconsax.lock_copy, 'Encryption Status', onTap: () => context.push(AppRouter.privacySecurity)),
                    _buildSettingItem(Iconsax.password_check_copy, 'Session Security', onTap: () => context.push(AppRouter.privacySecurity)),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildSettingsSection(
                  title: 'Notifications',
                  items: [
                    _buildToggleItem(Iconsax.notification_copy, 'Push Notifications', _isPushEnabled, (val) => setState(() => _isPushEnabled = val)),
                    _buildSettingItem(Iconsax.message_copy, 'Message Notifications', onTap: () => context.push(AppRouter.notificationSettings)),
                    _buildSettingItem(Iconsax.call_calling_copy, 'Call Notifications', onTap: () => context.push(AppRouter.notificationSettings)),
                    _buildSettingItem(Iconsax.video_play_copy, 'Reels Notifications', onTap: () => context.push(AppRouter.notificationSettings)),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildSettingsSection(
                  title: 'App Settings',
                  items: [
                    _buildToggleItem(
                      Iconsax.moon_copy, 
                      'Dark Theme', 
                      _isDarkTheme, 
                      (val) {
                        if (isPremium) {
                          setState(() => _isDarkTheme = val);
                        } else {
                          // Force dark theme for free users
                          setState(() => _isDarkTheme = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 5),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              content: GlassmorphicContainer(
                                width: double.infinity,
                                height: 70.h,
                                borderRadius: 16.r,
                                blur: 20,
                                alignment: Alignment.center,
                                border: 1,
                                linearGradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1).withValues(alpha: 0.9),
                                    const Color(0xFFA855F7).withValues(alpha: 0.8),
                                  ],
                                ),
                                borderGradient: LinearGradient(
                                  colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Row(
                                    children: [
                                      Icon(Iconsax.crown_1_copy, color: Colors.white, size: 24.sp),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Premium Feature',
                                              style: GoogleFonts.orbitron(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Theme customization is only for Pro members.',
                                              style: GoogleFonts.inter(
                                                fontSize: 10.sp,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          context.push(AppRouter.premium);
                                        },
                                        child: Text(
                                          'UPGRADE',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryNeon,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      isLocked: !isPremium,
                    ),
                    _buildToggleItem(Iconsax.data_copy, 'Data Usage Saver', _isDataSaver, (val) => setState(() => _isDataSaver = val)),
                    _buildSettingItem(Iconsax.folder_2_copy, 'Storage Management', onTap: () => context.push(AppRouter.storageManagement)),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildSettingsSection(
                  title: 'Support & About',
                  items: [
                    _buildSettingItem(Iconsax.info_circle_copy, 'Help Center', onTap: () => context.push(AppRouter.support)),
                    _buildSettingItem(Iconsax.message_question_copy, 'Report a Problem', onTap: () => context.push(AppRouter.reportProblem)),
                    _buildSettingItem(Iconsax.document_text_copy, 'Terms & Privacy Policy', onTap: () => context.push(AppRouter.privacyPolicy)),
                    _buildSettingItem(Iconsax.award_copy, 'About App', trailing: 'v1.0.4', onTap: () => context.push(AppRouter.about)),
                  ],
                ),
                SizedBox(height: 32.h),
                // Logout Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: GestureDetector(
                    onTap: () {
                      // Show confirmation dialog or just logout
                      context.go(AppRouter.login);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.logout_copy, color: Colors.redAccent, size: 20.sp),
                          SizedBox(width: 10.w),
                          Text(
                            'Logout Account',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                SizedBox(height: 40.h),
                Text(
                  'from\nCHIT CHAT LABS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 10.sp,
                    color: AppColors.textGrey,
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

  Widget _buildPremiumBanner() {
    return GestureDetector(
      onTap: () => context.push(AppRouter.premium),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 70.h,
        borderRadius: 20.r,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.2),
            const Color(0xFFA855F7).withValues(alpha: 0.1),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [const Color(0xFF6366F1).withValues(alpha: 0.5), Colors.transparent],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.crown_1_copy, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get Chit Chat Premium',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Unlock Multi-Device & Advanced Security',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
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
    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100.h,
      borderRadius: 20.r,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
      ),
      borderGradient: LinearGradient(
        colors: [AppColors.secondaryNeon.withOpacity(0.2), Colors.transparent],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundImage: profile.profilePicture != null && profile.profilePicture!.isNotEmpty
                  ? NetworkImage(profile.profilePicture!)
                  : null,
              child: profile.profilePicture == null || profile.profilePicture!.isEmpty
                  ? Icon(Icons.person, size: 30.r, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    profile.username,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push(AppRouter.editProfile),
              icon: Icon(Iconsax.edit_2_copy, color: AppColors.secondaryNeon, size: 20.sp),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildSettingsSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNeon.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildSettingItem(IconData icon, String title, {VoidCallback? onTap, String? trailing, String? subtitle}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white, size: 20.sp),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textGrey),
            )
          : null,
      trailing: trailing != null
          ? Text(
              trailing,
              style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textGrey),
            )
          : Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 14.sp),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value, Function(bool) onChanged, {bool isLocked = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 20.sp),
      title: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
          ),
          if (isLocked) ...[
            SizedBox(width: 8.w),
            Icon(Iconsax.crown_1_copy, color: AppColors.primaryNeon, size: 14.sp),
          ],
        ],
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.secondaryNeon,
        activeTrackColor: AppColors.secondaryNeon.withOpacity(0.2),
        inactiveThumbColor: AppColors.textGrey,
        inactiveTrackColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
