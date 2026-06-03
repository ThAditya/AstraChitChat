import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/router/app_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';
import 'package:chitchat/features/profile/presentation/screens/creator_dashboard_screen.dart';
import '../../domain/models/user_profile.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch profile on init
    Future.microtask(() => ref.read(myProfileProvider.notifier).fetchMyProfile());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(myProfileProvider);
    final profile = profileState.profile;

    if (profileState.isLoading && profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.secondaryNeon)),
      );
    }

    if (profileState.error != null && profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profileState.error!, style: const TextStyle(color: Colors.white)),
              ElevatedButton(
                onPressed: () => ref.read(myProfileProvider.notifier).fetchMyProfile(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('No profile found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const ParticleBackground(),
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  actions: [
                    IconButton(
                      onPressed: () => context.push(AppRouter.settings),
                      icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
                SliverToBoxAdapter(
                  child: _buildProfileHeader(profile),
                ),
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 0,
                  backgroundColor: AppColors.background,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(60.h),
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.secondaryNeon,
                        indicatorWeight: 2,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textGrey,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(icon: Icon(Iconsax.grid_1_copy, size: 20)),
                          Tab(icon: Icon(Iconsax.video_play_copy, size: 20)),
                          Tab(icon: Icon(Iconsax.video_circle_copy, size: 20)),
                          Tab(icon: Icon(Iconsax.notification_status_copy, size: 20)),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsGrid(profile),
                _buildReelsGrid(profile),
                _buildChannelVideosGrid(),
                _buildChannelActivityFeed(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          // Avatar with subtle glow
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryNeon.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 45.r,
                  backgroundColor: AppColors.surface,
                  child: Padding(
                    padding: EdgeInsets.all(2.r),
                    child: CircleAvatar(
                      radius: 43.r,
                      backgroundImage: profile.profilePicture != null && profile.profilePicture!.isNotEmpty
                          ? CachedNetworkImageProvider(profile.profilePicture!)
                          : null,
                      child: profile.profilePicture == null || profile.profilePicture!.isEmpty
                          ? Icon(Icons.person, size: 40.r, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
              if (profile.isOnline)
                Positioned(
                  bottom: 5,
                  right: 5,
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
          SizedBox(height: 12.h),

          // Name & Status
          Text(
            profile.name,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (profile.pronouns.isNotEmpty)
            Text(
              profile.pronouns,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textGrey,
              ),
            ),
          Text(
            'Digital creator',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
            ),
          ),
          Text(
            profile.isOnline ? 'Online' : (profile.lastSeen != null ? 'Last seen recently' : ''),
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: profile.isOnline ? AppColors.success : AppColors.textGrey,
            ),
          ),
          SizedBox(height: 16.h),

          // Bio
          if (profile.bio.isNotEmpty)
            Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          if (profile.website.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                profile.website,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.primaryNeon,
                ),
              ),
            ),
          SizedBox(height: 24.h),

          // Stats Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Posts', profile.stats.posts.toString()),
              _buildStat('Followers', profile.stats.followers.toString()),
              _buildStat('Following', profile.stats.following.toString()),
            ],
          ),
          SizedBox(height: 24.h),

          // Creator Dashboard Button
          _buildCreatorDashboardButton(),
          SizedBox(height: 16.h),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Edit Profile',
                  Iconsax.user_edit_copy,
                  onTap: () => context.push(AppRouter.editProfile),
                  isPrimary: true,
                ),
              ),
              SizedBox(width: 8.w),
              _buildSquareButton(Iconsax.security_safe_copy,
                  onTap: () => context.push(AppRouter.privacySecurity)),
            ],
          ),
          SizedBox(height: 24.h),

          // Highlights
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 1, // Start with just "Add Highlight" for now
              itemBuilder: (context, index) {
                if (index == 0) return _buildAddHighlight();
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildCreatorDashboardButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatorDashboardScreen()),
      ),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 48.h,
        borderRadius: 12.r,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.chart_2_copy,
                    color: const Color(0xFF818CF8), size: 16.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creator Dashboard',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      'Analytics, Earnings & Creator Tools',
                      style: GoogleFonts.inter(
                        color: AppColors.textGrey,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white54, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45.h,
        height: 45.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon,
      {VoidCallback? onTap, bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: label.isEmpty ? 45.h : double.infinity,
        height: 45.h,
        borderRadius: 12.r,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: isPrimary
              ? [
                  AppColors.secondaryNeon.withValues(alpha: 0.2),
                  AppColors.secondaryNeon.withValues(alpha: 0.05)
                ]
              : [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02)
                ],
        ),
        borderGradient: LinearGradient(
          colors: [
            isPrimary
                ? AppColors.secondaryNeon
                : Colors.white.withValues(alpha: 0.1),
            Colors.transparent
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            if (label.isNotEmpty) ...[
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddHighlight() {
    return GestureDetector(
      onTap: () => context.push('/coming-soon', extra: 'Add Highlight'),
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.textGrey.withValues(alpha: 0.5), width: 1),
              ),
              child: Icon(Iconsax.add_copy, color: Colors.white, size: 24.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              'New',
              style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightItem(String imageUrl) {
    return GestureDetector(
      onTap: () => context.push('/coming-soon', extra: 'View Highlight'),
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.secondaryNeon.withValues(alpha: 0.5),
                    width: 1.5),
              ),
              child: CircleAvatar(
                radius: 28.r,
                backgroundImage:
                    CachedNetworkImageProvider(imageUrl),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Highlight',
              style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsGrid(UserProfile profile) {
    return GridView.builder(
      padding: EdgeInsets.all(2.r),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 0, // Placeholder for actual posts
      itemBuilder: (context, index) {
        return Container();
      },
    );
  }

  Widget _buildReelsGrid(UserProfile profile) {
    return GridView.builder(
      padding: EdgeInsets.all(2.r),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 0, // Placeholder for actual reels
      itemBuilder: (context, index) {
        return Container();
      },
    );
  }

  Widget _buildChannelVideosGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(2.r),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 10,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://picsum.photos/seed/video_$index/800/450',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 8.h,
              left: 8.w,
              right: 8.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Amazing Long Form Video #$index',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(index + 1) * 12}K views • 2 days ago',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Icon(Icons.play_circle_outline, color: Colors.white.withValues(alpha: 0.8), size: 30.sp),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChannelActivityFeed() {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: CachedNetworkImageProvider(
                        'https://i.pravatar.cc/150?u=channel_$index'),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.video_library, color: Colors.white, size: 8.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                            fontSize: 13.sp, color: Colors.white),
                        children: [
                          const TextSpan(
                              text: 'User ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: ' is waiting for your next long video!',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Your video "Ep 2: Tech Journey" is trending',
                      style: GoogleFonts.inter(
                          fontSize: 11.sp, color: AppColors.primaryNeon),
                    ),
                  ],
                ),
              ),
              Text(
                '${index + 1}h',
                style: GoogleFonts.inter(
                    fontSize: 10.sp, color: AppColors.textGrey),
              ),
            ],
          ),
        )
            .animate()
            .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: (index * 50).ms)
            .fadeIn();
      },
    );
  }
}
