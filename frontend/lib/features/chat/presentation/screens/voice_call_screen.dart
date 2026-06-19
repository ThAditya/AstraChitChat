import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../../domain/models/chat_model.dart';

class VoiceCallScreen extends StatefulWidget {
  final ChatModel chat;

  const VoiceCallScreen({super.key, required this.chat});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  int _seconds = 0;
  Timer? _timer;
  String _callStatus = "Calling...";

  @override
  void initState() {
    super.initState();
    // Simulate call connecting after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _callStatus = "00:00";
          _startTimer();
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
          _callStatus = _formatDuration(Duration(seconds: _seconds));
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Animated Gradient Background
          const ParticleBackground(),
          
          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                
                // Security Banner (Animated)
                _buildSecurityBanner().animate().fadeIn(delay: 400.ms).slideY(begin: -0.5),
                
                SizedBox(height: 40.h),

                // Caller Information
                _buildCallerInfo(),

                const Spacer(),

                // Call Controls
                _buildCallControls(),
                
                SizedBox(height: 40.h),
                
                // End Call Button
                _buildEndCallButton(),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGlow() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppColors.primaryNeon.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds, curve: Curves.easeInOut),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryNeon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryNeon.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.shield_tick_copy, color: AppColors.primaryNeon, size: 18.sp),
          SizedBox(width: 12.w),
          Text(
            "SECURE END-TO-END ENCRYPTED CALL",
            style: GoogleFonts.orbitron(
              color: AppColors.primaryNeon,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallerInfo() {
    return Column(
      children: [
        // Pulsing Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            _buildPulseRing(1.2, 0.1),
            _buildPulseRing(1.5, 0.05),
            Container(
              width: 160.r,
              height: 160.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryNeon.withOpacity(0.3), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNeon.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(80.r),
                child: widget.chat.avatar.isNotEmpty
                    ? Image.network(widget.chat.avatar, fit: BoxFit.cover)
                    : Container(color: AppColors.surface, child: Icon(Iconsax.user_copy, size: 60.sp, color: Colors.white)),
              ),
            ),
          ],
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

        SizedBox(height: 32.h),

        Text(
          widget.chat.name,
          style: GoogleFonts.orbitron(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

        SizedBox(height: 12.h),

        Text(
          _callStatus,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: _callStatus == "Calling..." ? AppColors.textGrey : AppColors.primaryNeon,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildPulseRing(double scale, double opacity) {
    return Container(
      width: 160.r,
      height: 160.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryNeon.withOpacity(opacity), width: 2),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .scale(begin: const Offset(1, 1), end: Offset(scale, scale), duration: 2.seconds, curve: Curves.easeOut)
     .fadeOut();
  }

  Widget _buildCallControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildControlButton(Iconsax.microphone_slash_copy, "Mute", _isMuted, () {
                setState(() => _isMuted = !_isMuted);
              }),
              _buildControlButton(Iconsax.volume_high_copy, "Speaker", _isSpeakerOn, () {
                setState(() => _isSpeakerOn = !_isSpeakerOn);
              }),
              _buildControlButton(Iconsax.grid_1_copy, "Keypad", false, () {}),
            ],
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(Iconsax.bluetooth_copy, "Bluetooth", false, () {}),
              _buildControlButton(Iconsax.user_add_copy, "Add", false, () {}),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2);
  }

  Widget _buildControlButton(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: GlassmorphicContainer(
            width: 60.r,
            height: 60.r,
            borderRadius: 30.r,
            blur: 15,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              colors: isActive 
                  ? [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)]
                  : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
            ),
            borderGradient: LinearGradient(
              colors: isActive 
                  ? [AppColors.primaryNeon, AppColors.secondaryNeon]
                  : [Colors.white.withOpacity(0.1), Colors.transparent],
            ),
            child: Icon(
              icon, 
              color: isActive ? AppColors.primaryNeon : Colors.white, 
              size: 24.sp
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textGrey,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 72.r,
        height: 72.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          child: Icon(Iconsax.call_remove_copy, color: Colors.white, size: 32.sp),
        ),
      ),
    ).animate().scale(delay: 900.ms, duration: 400.ms, curve: Curves.elasticOut);
  }
}
