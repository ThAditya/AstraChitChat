import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/video_model.dart';

class VideoCard extends StatefulWidget {
  final VideoModel video;
  const VideoCard({super.key, required this.video});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _isSaved = false;
  bool _showSavedAnimation = false;

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
      if (_isSaved) _showSavedAnimation = true;
    });
    if (_isSaved) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSavedAnimation = false);
      });
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 380.h,
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
            SizedBox(height: 24.h),
            _buildMenuItem(Iconsax.play_add_copy, 'Add to Queue'),
            _buildMenuItem(_isSaved ? Iconsax.archive_tick_copy : Iconsax.archive_add_copy, _isSaved ? 'Remove from Library' : 'Save to Library', 
              onTap: () {
                Navigator.pop(context);
                _toggleSave();
              }),
            _buildMenuItem(Iconsax.export_1_copy, 'Share Video'),
            _buildMenuItem(Iconsax.dislike_copy, 'Not Interested'),
            _buildMenuItem(Iconsax.flag_copy, 'Report', isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white, size: 22.sp),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: CachedNetworkImage(
                      imageUrl: widget.video.thumbnailUrl,
                      height: 210.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppColors.surface),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.r),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      widget.video.duration,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              // Video Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: CachedNetworkImageProvider(widget.video.creatorAvatar),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              widget.video.creatorName,
                              style: GoogleFonts.inter(
                                color: AppColors.textGrey,
                                fontSize: 12.sp,
                              ),
                            ),
                            if (widget.video.isVerified) ...[
                              SizedBox(width: 4.w),
                              Icon(Icons.check_circle, color: AppColors.primaryNeon, size: 12.sp),
                            ],
                            SizedBox(width: 8.w),
                            Text(
                              '• ${widget.video.views} • ${widget.video.uploadTime}',
                              style: GoogleFonts.inter(
                                color: AppColors.textGrey,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleSave,
                        icon: Icon(
                          _isSaved ? Iconsax.archive_tick_copy : Iconsax.archive_add_copy,
                          color: _isSaved ? AppColors.primaryNeon : Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      IconButton(
                        onPressed: _showMoreOptions,
                        icon: Icon(Icons.more_vert, color: Colors.white, size: 20.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (_showSavedAnimation)
            Positioned.fill(
              child: Center(
                child: GlassmorphicContainer(
                  width: 160.w,
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
                      Icon(Iconsax.archive_tick_copy, color: AppColors.primaryNeon, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Saved to Library',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale().fadeOut(delay: 1.5.seconds),
              ),
            ),
        ],
      ),
    );
  }
}
