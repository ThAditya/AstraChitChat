import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/premium_snackbar.dart';
import '../../../chat/domain/models/chat_model.dart';
import '../../../chat/presentation/providers/social_providers.dart';
import '../../domain/models/user_profile.dart';
import '../providers/profile_provider.dart';

class CreatorProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const CreatorProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends ConsumerState<CreatorProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startChat(UserProfile profile) {
    final chat = ChatModel(
      id: profile.id,
      name: profile.name,
      lastMessage: "Hey, I just found your profile on Explore!",
      avatar: profile.profilePicture ?? '',
      time: "Just now",
      isOnline: profile.isOnline,
    );

    ref.read(chatsProvider.notifier).addChat(chat);
    context.push(AppRouter.chatDetail, extra: chat);
  }

  void _showShareSheet(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 300.h,
        borderRadius: 24.r,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Share Profile',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Iconsax.link_copy, 'Copy Link'),
                _buildShareOption(Iconsax.whatsapp_copy, 'WhatsApp'),
                _buildShareOption(Iconsax.instagram_copy, 'Instagram'),
                _buildShareOption(Iconsax.sms_copy, 'More'),
              ],
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNeon,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'DONE',
                  style: GoogleFonts.orbitron(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 600.h,
        borderRadius: 24.r,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.95),
            AppColors.surface.withValues(alpha: 0.85),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMoreOption(Iconsax.slash_copy, 'Restrict', isRed: true, onTap: () {
                    context.pop();
                    _showConfirmationDialog(context, profile, 'Restrict', 'Restricting will limit their interactions with your profile without them knowing.');
                  }),
                  _buildMoreOption(Iconsax.user_minus_copy, 'Block', isRed: true, onTap: () {
                    context.pop();
                    _showConfirmationDialog(context, profile, 'Block', 'Are you sure you want to block ${profile.name}? They won\'t be able to find your profile, posts or story on Chit Chat.');
                  }),
                  _buildMoreOption(Iconsax.warning_2_copy, 'Report', isRed: true, onTap: () {
                    context.pop();
                    _showConfirmationDialog(context, profile, 'Report', 'Report ${profile.name} for community guideline violations?');
                  }),
                  _buildMoreOption(Iconsax.info_circle_copy, 'About this account', onTap: () {
                    context.pop();
                    _showInfoSheet(context, 'About this Account', 'Joined: January 2024\nLocation: ${profile.location.isNotEmpty ? profile.location : "Unknown"}\nAccount Type: Verified Creator');
                  }),
                  _buildMoreOption(Iconsax.activity_copy, 'See shared activity', onTap: () {
                    context.pop();
                    _showInfoSheet(context, 'Shared Activity', 'You both follow 12 mutual creators.\nYou have liked 4 of their recent reels.');
                  }),
                  _buildMoreOption(Iconsax.eye_slash_copy, 'Hide your story', onTap: () {
                    context.pop();
                    PremiumSnackBar.show(
                      context, 
                      'Your stories are now hidden from ${profile.name}',
                      icon: Iconsax.eye_slash_copy
                    );
                  }),
                  _buildMoreOption(Iconsax.user_remove_copy, 'Remove follower', onTap: () {
                    context.pop();
                    _showConfirmationDialog(context, profile, 'Remove Follower', 'Chit Chat won\'t tell ${profile.name} they were removed from your followers.');
                  }),
                  _buildMoreOption(Iconsax.link_copy, 'Copy profile URL', onTap: () {
                    context.pop();
                    Clipboard.setData(ClipboardData(text: 'https://chitchat.app/profile/${profile.username}')).then((_) {
                      PremiumSnackBar.show(
                        context, 
                        'Profile link copied to clipboard',
                        icon: Iconsax.link_copy
                      );
                    });
                  }),
                  _buildMoreOption(Iconsax.export_copy, 'Share this profile', onTap: () {
                    context.pop();
                    _showShareSheet(context, profile);
                  }),
                  _buildMoreOption(Iconsax.barcode_copy, 'QR code', onTap: () {
                    context.pop();
                    _showQRCode(context, profile);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, UserProfile profile, String action, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(action, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PremiumSnackBar.show(
                context, 
                '$action: Action confirmed',
                icon: Iconsax.tick_circle_copy,
                color: AppColors.success
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(action, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showInfoSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 250.h,
        borderRadius: 24.r,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [AppColors.surface.withValues(alpha: 0.9), AppColors.surface.withValues(alpha: 0.8)],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),
              Text(content, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14.sp, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Profile QR Code', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            Container(
              width: 200.r,
              height: 200.r,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.qr_code_2_rounded, size: 150.sp, color: Colors.black),
            ),
            SizedBox(height: 20.h),
            Text(profile.username, style: GoogleFonts.inter(color: AppColors.primaryNeon, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon,
      {VoidCallback? onTap, bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 45.h,
        borderRadius: 12.r,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: isPrimary
              ? [
                  AppColors.primaryNeon.withValues(alpha: 0.2),
                  AppColors.primaryNeon.withValues(alpha: 0.05)
                ]
              : [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02)
                ],
        ),
        borderGradient: LinearGradient(
          colors: [
            isPrimary
                ? AppColors.primaryNeon
                : Colors.white.withValues(alpha: 0.1),
            Colors.transparent
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
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
        ),
      ),
    );
  }

  Widget _buildMoreOption(IconData icon, String label, {bool isRed = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isRed ? Colors.redAccent : Colors.white, size: 22.sp),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: isRed ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
      onTap: onTap ?? () {
        Navigator.pop(context);
        PremiumSnackBar.show(
          context, 
          '$label: Action completed',
          icon: icon
        );
      },
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.sp),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider(widget.userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data: (profile) => Stack(
          children: [
            const ParticleBackground(),
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: AppColors.background,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => _showShareSheet(context, profile),
                        icon: const Icon(Iconsax.share_copy, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () => _showMoreOptions(context, profile),
                        icon: const Icon(Iconsax.more_copy, color: Colors.white),
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
                          indicatorColor: AppColors.primaryNeon,
                          indicatorWeight: 2,
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textGrey,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(icon: Icon(Iconsax.video_play_copy, size: 20)),
                            Tab(icon: Icon(Iconsax.video_circle_copy, size: 20)),
                            Tab(icon: Icon(Iconsax.notification_status_copy, size: 20)),
                            Tab(icon: Icon(Iconsax.info_circle_copy, size: 20)),
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
                  _buildReelsGrid(profile),
                  _buildVideosList(profile),
                  _buildHighlightsList(profile),
                  _buildAboutSection(profile),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading profile', style: GoogleFonts.inter(color: Colors.white)),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider(widget.userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
                      color: AppColors.primaryNeon.withValues(alpha: 0.3),
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
                      backgroundImage: profile.profilePicture != null
                          ? CachedNetworkImageProvider(profile.profilePicture!)
                          : null,
                      child: profile.profilePicture == null
                          ? Icon(Iconsax.user_copy, size: 40.sp, color: Colors.white)
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

          // Name & Category
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.name,
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // We'll need to add isVerified to UserProfile if it's not there,
              // but I saw it in the User model so it should be in UserProfile too.
              // Let me check.
              SizedBox(width: 6.w),
              Icon(Iconsax.verify_copy,
                  color: AppColors.primaryNeon, size: 20.sp),
            ],
          ),
          Text(
            profile.category,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryNeon,
            ),
          ),
          Text(
            profile.isOnline ? 'Online' : 'Recently Active',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: profile.isOnline ? AppColors.success : AppColors.textGrey,
            ),
          ),
          SizedBox(height: 16.h),

          // Bio
          Text(
            profile.bio,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),

          // Stats Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Followers', profile.stats.followers.toString()),
              _buildStat('Following', profile.stats.following.toString()),
              _buildStat('Likes', profile.stats.likes.toString()),
            ],
          ),
          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  profile.isFollowing == true ? 'Following' : 'Follow',
                  Iconsax.user_add_copy,
                  onTap: () {},
                  isPrimary: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildQuickActionButton(
                  'Message',
                  Iconsax.message_copy,
                  onTap: () => _startChat(profile),
                  isPrimary: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Highlights - (Using interests as placeholder or keeping it empty for now)
          if (profile.interests.isNotEmpty)
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: profile.interests.length,
                itemBuilder: (context, index) {
                  return _buildHighlightItem(profile, index);
                },
              ),
            ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildHighlightItem(UserProfile profile, int index) {
    return Container(
      margin: EdgeInsets.only(right: 16.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primaryNeon.withValues(alpha: 0.5),
                  width: 1.5),
            ),
            child: CircleAvatar(
              radius: 28.r,
              backgroundColor: AppColors.surface,
              child: Icon(Iconsax.star_copy, color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            profile.interests[index],
            style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsGrid(UserProfile profile) {
    // Placeholder for actual reels
    return GridView.builder(
      padding: EdgeInsets.all(2.r),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: profile.stats.posts > 0 ? profile.stats.posts : 0,
      itemBuilder: (context, index) {
        return Container(
          color: AppColors.surface,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Icon(Iconsax.video_play_copy, color: Colors.white24, size: 30),
              Positioned(
                bottom: 8.h,
                left: 8.w,
                child: Row(
                  children: [
                    Icon(Iconsax.play_copy, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${(index + 1) * 2}K',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 50).ms);
      },
    );
  }

  Widget _buildVideosList(UserProfile profile) {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: 0, // Placeholder
      itemBuilder: (context, index) {
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHighlightsList(UserProfile profile) {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: 0, // Placeholder
      itemBuilder: (context, index) {
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAboutSection(UserProfile profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEngagementCard(profile),
          SizedBox(height: 24.h),
          _buildAboutItem(Iconsax.info_circle_copy, 'Account Info',
              'Member since ${profile.id.substring(0, 4) == "user" ? "Recently" : "Jan 2024"}\n${profile.location.isNotEmpty ? profile.location : "Location hidden"}'),
          if (profile.website.isNotEmpty)
            _buildAboutItem(Iconsax.link_copy, 'Links', profile.website),
          _buildAboutItem(Iconsax.security_user_copy, 'Security', 'Profile secured by Chit Chat'),
        ],
      ),
    );
  }

  Widget _buildEngagementCard(UserProfile profile) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 120.h,
      borderRadius: 20.r,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
      ),
      borderGradient: LinearGradient(
        colors: [AppColors.primaryNeon.withOpacity(0.2), Colors.transparent],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildEngagementStat('Posts', profile.stats.posts.toString()),
            Container(width: 1, color: Colors.white.withOpacity(0.1)),
            _buildEngagementStat('Total Likes', profile.stats.likes.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementStat(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNeon,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutItem(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryNeon, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
