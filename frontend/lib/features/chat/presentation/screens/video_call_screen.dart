import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/chat_model.dart';

class VideoCallScreen extends StatefulWidget {
  final ChatModel chat;

  const VideoCallScreen({super.key, required this.chat});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;
  int _seconds = 0;
  Timer? _timer;
  Offset _pipOffset = Offset(20.w, 80.h);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
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

  void _showParticipants() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 400.h,
        borderRadius: 32.r,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background.withOpacity(0.9),
            AppColors.background.withOpacity(0.8),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Text(
                    "In this call",
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      "${widget.chat.isGroup ? (widget.chat.members?.length ?? 1) : 2} Active",
                      style: TextStyle(color: AppColors.primaryNeon, fontSize: 10.sp),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                children: [
                  _buildParticipantItem("You", 'https://ui-avatars.com/api/?name=Me', true),
                  if (!widget.chat.isGroup)
                    _buildParticipantItem(widget.chat.name, widget.chat.avatar, true)
                  else if (widget.chat.members != null)
                    ...widget.chat.members!.map((m) => _buildParticipantItem(m.name, m.avatar, m.isOnline)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantItem(String name, String avatar, bool isActive) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatar),
          ),
          if (isActive)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 10.r,
                height: 10.r,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(name, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.microphone_2_copy, color: Colors.white54, size: 18.sp),
          SizedBox(width: 12.w),
          Icon(Iconsax.video_copy, color: Colors.white54, size: 18.sp),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Remote Video (Full Screen)
          _buildRemoteVideo(),

          // 2. Gradient Overlay for readability
          _buildGradientOverlays(),

          // 3. Top Information Bar
          _buildTopOverlay(),

          // 4. Draggable Self Preview
          _buildSelfPreview(),

          // 5. Floating Control Panel
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildRemoteVideo() {
    return Positioned.fill(
      child: Image.network(
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&auto=format&fit=crop&q=60',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildGradientOverlays() {
    return Positioned.fill(
      child: Column(
        children: [
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 250.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.shield_tick_copy, color: AppColors.success, size: 14.sp),
                          SizedBox(width: 8.w),
                          Text(
                            "SECURE",
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    _buildQualityIndicator(),
                  ],
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Iconsax.close_circle_copy, color: Colors.white, size: 32),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              widget.chat.name,
              style: GoogleFonts.orbitron(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn().slideY(begin: -0.2),
            Text(
              _formatDuration(Duration(seconds: _seconds)),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityIndicator() {
    return Row(
      children: List.generate(4, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: 3.w,
          height: (index + 2) * 3.h,
          decoration: BoxDecoration(
            color: index < 3 ? AppColors.success : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      }),
    );
  }

  Widget _buildSelfPreview() {
    return Positioned(
      left: _pipOffset.dx,
      top: _pipOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _pipOffset += details.delta;
          });
        },
        child: Container(
          width: 120.w,
          height: 180.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              children: [
                _isVideoOff 
                    ? Container(color: Colors.grey[900], child: Center(child: Icon(Iconsax.camera_slash_copy, color: Colors.white)))
                    : Image.network(
                        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop&q=60',
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.user_copy, size: 10.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 40.h,
      left: 20.w,
      right: 20.w,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 100.h,
        borderRadius: 32.r,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: _isMuted ? Iconsax.microphone_slash_copy : Iconsax.microphone_2_copy,
              onTap: () => setState(() => _isMuted = !_isMuted),
              isActive: _isMuted,
            ),
            _buildControlButton(
              icon: _isVideoOff ? Iconsax.camera_slash_copy : Iconsax.camera_copy,
              onTap: () => setState(() => _isVideoOff = !_isVideoOff),
              isActive: _isVideoOff,
            ),
            _buildControlButton(
              icon: Iconsax.repeat_copy,
              onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
            ),
            _buildControlButton(
              icon: Iconsax.monitor_copy,
              onTap: () {},
            ),
            _buildControlButton(
              icon: Iconsax.people_copy,
              onTap: () => _showParticipants(),
            ),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent,
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Icon(Iconsax.call_remove_copy, color: Colors.white, size: 28.sp),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutQuart),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.primaryNeon : Colors.white,
          size: 22.sp,
        ),
      ),
    );
  }
}
