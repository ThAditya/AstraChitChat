import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _messages = true;
  bool _calls = true;
  bool _reels = true;
  bool _mentions = true;
  bool _sound = true;
  bool _vibrate = true;

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
          'Notifications',
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
                _buildSectionHeader('PUSH NOTIFICATIONS'),
                _buildToggleItem(Iconsax.message_copy, 'Messages', _messages, (v) => setState(() => _messages = v)),
                _buildToggleItem(Iconsax.call_calling_copy, 'Calls', _calls, (v) => setState(() => _calls = v)),
                _buildToggleItem(Iconsax.video_play_copy, 'Reels & Videos', _reels, (v) => setState(() => _reels = v)),
                _buildToggleItem(Iconsax.user_add_copy, 'Mentions & Tags', _mentions, (v) => setState(() => _mentions = v)),
                SizedBox(height: 32.h),
                _buildSectionHeader('ALERTS'),
                _buildToggleItem(Iconsax.volume_high_copy, 'Sound', _sound, (v) => setState(() => _sound = v)),
                _buildToggleItem(Iconsax.mobile_copy, 'Vibrate', _vibrate, (v) => setState(() => _vibrate = v)),
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

  Widget _buildToggleItem(IconData icon, String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20.sp),
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.secondaryNeon,
          activeTrackColor: AppColors.secondaryNeon.withOpacity(0.2),
          inactiveThumbColor: AppColors.textGrey,
          inactiveTrackColor: Colors.white.withOpacity(0.05),
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
