import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/reel_model.dart';

class ReelItem extends StatefulWidget {
  final ReelModel reel;
  const ReelItem({super.key, required this.reel});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isSaved = false;
  bool _isAudioSaved = false;
  bool _showSavedAnimation = false;
  String _savedMessage = '';
  bool _showHeartAnimation = false;
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.reel.isLiked;
    _likesCount = _parseLikes(widget.reel.likes);
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
          _controller.play();
        });
      });
  }

  int _parseLikes(String likes) {
    if (likes.endsWith('K')) {
      return (double.parse(likes.replaceAll('K', '')) * 1000).toInt();
    } else if (likes.endsWith('M')) {
      return (double.parse(likes.replaceAll('M', '')) * 1000000).toInt();
    }
    return int.tryParse(likes) ?? 0;
  }

  String _formatLikes(int likes) {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    }
    return likes.toString();
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      _toggleLike();
    }
    setState(() {
      _showHeartAnimation = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showHeartAnimation = false;
        });
      }
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likesCount++;
      } else {
        _likesCount--;
      }
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        borderRadius: 30.r,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.9), Colors.black.withOpacity(0.8)],
        ),
        borderGradient: LinearGradient(
          colors: [AppColors.primaryNeon.withOpacity(0.3), Colors.transparent],
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
            SizedBox(height: 16.h),
            Text(
              '${widget.reel.comments} Comments',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(20.r),
                itemCount: 10,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=10'),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'user_name_$index',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'This design is absolutely fire! Love the neon aesthetic. 🔥✨',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Text('2h', style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
                                SizedBox(width: 16.w),
                                Text('Reply', style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Icon(Iconsax.heart_copy, size: 14.sp, color: Colors.white38),
                          Text('12', style: TextStyle(color: Colors.white38, fontSize: 10.sp)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 12.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundImage: NetworkImage(widget.reel.creatorAvatar),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 14.sp),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Text(
                    'Post',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryNeon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareReel() {
    Share.share('Check out this amazing reel by ${widget.reel.creatorName} on ChitChat!\n\n${widget.reel.caption}\n${widget.reel.videoUrl}');
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 400.h,
        borderRadius: 30.r,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.9), Colors.black.withOpacity(0.8)],
        ),
        borderGradient: LinearGradient(
          colors: [AppColors.primaryNeon.withOpacity(0.3), Colors.transparent],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              SizedBox(height: 24.h),
              _buildSettingItem(Iconsax.info_circle_copy, 'Report Content', isDestructive: true),
              _buildSettingItem(Iconsax.eye_slash_copy, 'Not Interested'),
              _buildSettingItem(Iconsax.copy_copy, 'Copy Link', onTap: () {
                Navigator.pop(context);
                _savedMessage = 'Link Copied!';
                setState(() => _showSavedAnimation = true);
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _showSavedAnimation = false);
                });
              }),
              _buildSettingItem(Iconsax.user_minus_copy, 'Unfollow ${widget.reel.creatorName}'),
              _buildSettingItem(Iconsax.export_1_copy, 'Share to...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () => Navigator.pop(context),
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white, size: 22.sp),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontSize: 15.sp,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
      if (_isSaved) {
        _savedMessage = 'Saved to Reels';
        _showSavedAnimation = true;
      }
    });
    if (_isSaved) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSavedAnimation = false);
      });
    }
  }

  void _toggleAudioSave() {
    setState(() {
      _isAudioSaved = !_isAudioSaved;
      if (_isAudioSaved) {
        _savedMessage = 'Audio Saved to Library';
        _showSavedAnimation = true;
      }
    });
    if (_isAudioSaved) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSavedAnimation = false);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        _isInitialized
            ? GestureDetector(
                onDoubleTap: _handleDoubleTap,
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  });
                },
                child: VideoPlayer(_controller),
              )
            : Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryNeon),
                ),
              ),

        // Heart Animation on Double Tap
        if (_showHeartAnimation)
          Center(
            child: Icon(
              Icons.favorite,
              color: Colors.white,
              size: 100.sp,
            ).animate().scale(
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                ).fadeOut(delay: 400.ms),
          ),

        // Saved Animation
        if (_showSavedAnimation)
          Center(
            child: GlassmorphicContainer(
              width: 200.w,
              height: 50.h,
              borderRadius: 25.r,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.6)],
              ),
              borderGradient: LinearGradient(
                colors: [AppColors.primaryNeon.withOpacity(0.5), Colors.transparent],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _savedMessage.contains('Link') ? Iconsax.copy_copy : Iconsax.archive_tick_copy,
                    color: AppColors.primaryNeon,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _savedMessage,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale().slideY(begin: 0.2, end: 0).fadeOut(delay: 1.5.seconds),
          ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
              stops: const [0.0, 0.2, 0.7, 1.0],
            ),
          ),
        ),

        // Right Actions
        Positioned(
          right: 16.w,
          bottom: 100.h,
          child: Column(
            children: [
              GestureDetector(
                onTap: _toggleLike,
                child: _buildActionItem(
                  _isLiked ? Icons.favorite : Iconsax.heart_copy,
                  _formatLikes(_likesCount),
                  color: _isLiked ? Colors.redAccent : Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _showComments,
                child: _buildActionItem(Iconsax.message_2_copy, widget.reel.comments),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _shareReel,
                child: _buildActionItem(Iconsax.send_2_copy, widget.reel.shares),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _toggleSave,
                child: _buildActionItem(
                  _isSaved ? Iconsax.archive_tick_copy : Iconsax.archive_add_copy,
                  _isSaved ? "Saved" : "Save",
                  color: _isSaved ? AppColors.primaryNeon : Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _toggleAudioSave,
                child: _buildActionItem(
                  _isAudioSaved ? Iconsax.music_play_copy : Iconsax.music_copy,
                  "Audio",
                  color: _isAudioSaved ? AppColors.primaryNeon : Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _showSettings,
                child: const Icon(Iconsax.more_copy, color: Colors.white),
              ),
            ],
          ).animate().slideX(begin: 1, duration: 600.ms, curve: Curves.easeOutQuart),
        ),

        // Bottom Info
        Positioned(
          left: 16.w,
          right: 80.w,
          bottom: 40.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: NetworkImage(widget.reel.creatorAvatar),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    widget.reel.creatorName,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (widget.reel.isVerified) ...[
                    SizedBox(width: 4.w),
                    Icon(Iconsax.verify_copy, color: AppColors.primaryNeon, size: 14.sp),
                  ],
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Follow',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                widget.reel.caption,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Iconsax.music_copy, color: Colors.white, size: 14.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SizedBox(
                      height: 20.h,
                      child: Text(
                        widget.reel.musicName,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12.sp),
                        maxLines: 1,
                      ).animate(onPlay: (controller) => controller.repeat())
                       .moveX(begin: 100, end: -200, duration: 8.seconds),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ),

        // Video Progress Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: AppColors.primaryNeon,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.white10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String count, {Color color = Colors.white}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30.sp),
        SizedBox(height: 4.h),
        Text(
          count,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
