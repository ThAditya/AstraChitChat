import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LiveStreamScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;

  const LiveStreamScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
  });

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [
    {'user': 'Sarah', 'text': 'This is amazing! 🔥'},
    {'user': 'Mike', 'text': 'How do you do that effect?'},
    {'user': 'Elena', 'text': 'Love the background music'},
    {'user': 'Alex', 'text': 'When is the next stream?'},
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Video Feed
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://picsum.photos/seed/${widget.userName}/1080/1920',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Top Info Bar
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  _buildCreatorInfo(),
                  const Spacer(),
                  _buildLiveBadge(),
                  SizedBox(width: 8.w),
                  _buildViewerCount(),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ),

          // Comments Section
          Positioned(
            bottom: 100.h,
            left: 16.w,
            right: 16.w,
            child: SizedBox(
              height: 200.h,
              child: ListView.builder(
                reverse: true,
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[_comments.length - 1 - index];
                  return _buildCommentItem(comment).animate().fadeIn().slideX(begin: -0.2);
                },
              ),
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundImage: CachedNetworkImageProvider(widget.userAvatar),
          ),
          SizedBox(width: 8.w),
          Text(
            widget.userName,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.secondaryNeon,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'Follow',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        'LIVE',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildViewerCount() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 12),
          SizedBox(width: 4.w),
          Text(
            '1.2K',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, String> comment) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${comment['user']}: ',
            style: GoogleFonts.inter(
              color: AppColors.secondaryNeon,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
          Expanded(
            child: Text(
              comment['text']!,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _commentController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Say something...',
                  hintStyle: GoogleFonts.inter(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      _comments.add({'user': 'You', 'text': val});
                      _commentController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(width: 12.w),
          _buildCircleAction(Iconsax.heart_copy, Colors.redAccent),
          SizedBox(width: 12.w),
          _buildCircleAction(Iconsax.gift_copy, Colors.amber),
          SizedBox(width: 12.w),
          _buildCircleAction(Iconsax.export_1_copy, Colors.white),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, Color color) {
    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: color, size: 22.sp),
      ),
    );
  }
}
