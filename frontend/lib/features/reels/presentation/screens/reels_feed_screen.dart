import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/reel_model.dart';
import '../widgets/reel_item.dart';
import '../widgets/videos_tab.dart';
import '../widgets/following_tab.dart';

class ReelsFeedScreen extends StatefulWidget {
  const ReelsFeedScreen({super.key});

  @override
  State<ReelsFeedScreen> createState() => _ReelsFeedScreenState();
}

class _ReelsFeedScreenState extends State<ReelsFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Content
          TabBarView(
            controller: _tabController,
            children: [
              const FollowingTab(),
              _buildReelsFeed(),
              const VideosTab(),
            ],
          ),

          // Top Glass TabBar (Floating for Reels, solid for others)
          _buildTopNavigation(),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    return AnimatedBuilder(
      animation: _tabController.animation!,
      builder: (context, child) {
        final double value = _tabController.animation!.value;
        final bool isReels = value > 0.5 && value < 1.5;
        
        return SafeArea(
          child: Container(
            height: 70.h,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Center(
              child: GlassmorphicContainer(
                width: 320.w,
                height: 50.h,
                borderRadius: 25.r,
                blur: 15,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(isReels ? 0.1 : 0.05),
                    Colors.white.withOpacity(isReels ? 0.05 : 0.02),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    AppColors.primaryNeon.withOpacity(0.2),
                    AppColors.secondaryNeon.withOpacity(0.2),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNeon.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  indicatorPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: EdgeInsets.all(4.r),
                  tabs: const [
                    Tab(text: 'Following'),
                    Tab(text: 'Reels'),
                    Tab(text: 'Videos'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReelsFeed() {
    return mockReelsData.isEmpty 
      ? _buildEmptyState()
      : PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: mockReelsData.length,
          itemBuilder: (context, index) {
            return ReelItem(reel: mockReelsData[index]);
          },
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.video_play_copy, size: 64.sp, color: AppColors.textGrey),
          SizedBox(height: 16.h),
          Text(
            'No Content Yet',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
