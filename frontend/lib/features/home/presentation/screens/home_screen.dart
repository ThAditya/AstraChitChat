import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/features/chat/domain/models/chat_model.dart' as chat_model;
import 'package:chitchat/features/stories/presentation/widgets/story_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/models/mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Let MainScreen handle background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 120.h), // Extra padding for bottom bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              
              // 1. Top App Bar
              _buildAppBar(context),
              
              SizedBox(height: 24.h),
              
              // 2. Welcome Section
              _buildWelcomeSection(context),
              
              SizedBox(height: 24.h),

              // 2.5 Stories Section
              const StoryBar(),
              
              SizedBox(height: 24.h),
              
              // 3. Recent Chats
              _buildSectionHeader("Recent Chats", onTap: () => context.push(AppRouter.chat)),
              SizedBox(height: 16.h),
              _buildRecentChats(context),
              
              SizedBox(height: 32.h),
              
              // 4. Trending Reels
              _buildSectionHeader("Trending Reels", onTap: () {}), // Could point to Reels tab
              SizedBox(height: 16.h),
              _buildTrendingReels(context),
              
              SizedBox(height: 32.h),
              
              // 5. Long Videos
              _buildSectionHeader(
                " Videos", 
                onTap: () => context.push('/coming-soon', extra: 'Videos Library'),
              ),
              SizedBox(height: 16.h),
              _buildLongVideos(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: Icon(Icons.chat_bubble_rounded, size: 24.sp, color: Colors.white),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'CHIT CHAT',
                style: GoogleFonts.orbitron(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(
                Iconsax.search_normal_1_copy, 
                onTap: () => context.push(AppRouter.videoSearch),
              ),
              SizedBox(width: 12.w),
              _buildIconButton(Iconsax.notification_copy, hasBadge: true, onTap: () => context.push(AppRouter.notifications)),
              SizedBox(width: 12.w),
              _buildIconButton(
                Iconsax.direct_copy,
                onTap: () => context.push(AppRouter.chat),
                isChat: true,
              ),
            ],
          ),
        ],
      ).animate().fadeIn().slideY(begin: -0.2),
    );
  }

  Widget _buildIconButton(IconData icon, {bool hasBadge = false, VoidCallback? onTap, bool isChat = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: isChat ? AppColors.primaryNeon.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isChat 
                ? AppColors.primaryNeon.withOpacity(0.2)
                : Colors.white.withOpacity(0.05)
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon, 
              size: 20.sp, 
              color: isChat ? AppColors.primaryNeon : Colors.white
            ),
            if (hasBadge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryNeon,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryNeon.withOpacity(0.1),
              AppColors.secondaryNeon.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, Creative!",
              style: GoogleFonts.orbitron(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "What's happening in your secure circle today?",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              "See All",
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.primaryNeon,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChats(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        scrollDirection: Axis.horizontal,
        itemCount: mockChats.length,
        itemBuilder: (context, index) {
          final chat = mockChats[index];
          return Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: GestureDetector(
              onTap: () {
                // Convert ChatPreview to ChatModel for navigation
                final model = chat_model.ChatModel(
                  id: index.toString(),
                  name: chat.name,
                  lastMessage: chat.lastMessage,
                  avatar: chat.avatar,
                  time: chat.time,
                  isOnline: chat.isOnline,
                );
                context.push(AppRouter.chatDetail, extra: model);
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: CircleAvatar(
                          radius: 30.r,
                          backgroundColor: AppColors.surface,
                          backgroundImage: NetworkImage(chat.avatar),
                        ),
                      ),
                      if (chat.isOnline)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 14.r,
                            height: 14.r,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.background, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
    );
  }

  Widget _buildTrendingReels(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        scrollDirection: Axis.horizontal,
        itemCount: mockReels.length,
        itemBuilder: (context, index) {
          final reel = mockReels[index];
          return GestureDetector(
            onTap: () => context.push(AppRouter.home), // Should ideally switch tab, but will at least refresh home/reels
            child: Container(
              width: 140.w,
              margin: EdgeInsets.only(right: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                image: DecorationImage(
                  image: NetworkImage(reel.thumbnail),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                padding: EdgeInsets.all(12.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reel.creator,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.play_circle_fill_rounded, size: 12.sp, color: Colors.white70),
                        SizedBox(width: 4.w),
                        Text(
                          reel.views,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
    );
  }

  Widget _buildLongVideos(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockVideos.length,
      itemBuilder: (context, index) {
        final video = mockVideos[index];
        return GestureDetector(
          onTap: () => context.push('/coming-soon', extra: video.title),
          child: Container(
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 180.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                        image: DecorationImage(
                          image: NetworkImage(video.thumbnail),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12.r,
                      right: 12.r,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          video.duration,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 65.h),
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNeon.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow_rounded, color: AppColors.primaryNeon, size: 30.sp),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: NetworkImage("https://ui-avatars.com/api/?name=${video.creator}&background=random"),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "${video.creator} • ${video.views}",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.more_vert_rounded, color: AppColors.textGrey, size: 20.sp),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }
}


