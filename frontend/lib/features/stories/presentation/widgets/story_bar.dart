import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/features/stories/domain/models/story_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/features/stories/presentation/screens/story_viewer_screen.dart';
import 'package:chitchat/features/stories/presentation/screens/story_upload_screen.dart';

class StoryBar extends StatelessWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: mockStories.length,
        itemBuilder: (context, index) {
          final story = mockStories[index];
          if (index == 0) return _buildMyStory(context, story);
          return _buildStoryCircle(context, story);
        },
      ),
    );
  }

  Widget _buildMyStory(BuildContext context, StoryModel story) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StoryUploadScreen()),
      ),
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 70.r,
                  height: 70.r,
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32.r,
                    backgroundImage: CachedNetworkImageProvider(story.creatorAvatar),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: Icon(Iconsax.add_copy, size: 12.sp, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              "My Story",
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCircle(BuildContext context, StoryModel story) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryViewerScreen(stories: mockStories, initialIndex: mockStories.indexOf(story)),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Story Ring
                Container(
                  width: 70.r,
                  height: 70.r,
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story.isLive 
                      ? const LinearGradient(colors: [Color(0xFFFF0000), Color(0xFFFF5C00)])
                      : story.isCloseFriend
                        ? const LinearGradient(colors: [Color(0xFF00FF00), Color(0xFF00AD00)])
                        : story.isUnviewed 
                          ? AppColors.primaryGradient 
                          : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.1)]),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 30.r,
                      backgroundImage: CachedNetworkImageProvider(story.creatorAvatar),
                    ),
                  ),
                ),
                // Live Badge
                if (story.isLive)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: AppColors.background, width: 1),
                      ),
                      child: Text(
                        "LIVE",
                        style: GoogleFonts.inter(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              story.creatorName,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: story.isUnviewed ? Colors.white : AppColors.textGrey,
                fontWeight: story.isUnviewed ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
