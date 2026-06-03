import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';
import 'package:chitchat/features/home/presentation/screens/home_screen.dart';
import 'package:chitchat/features/reels/presentation/screens/reels_feed_screen.dart';
import 'package:chitchat/features/reels/presentation/screens/upload_reel_screen.dart';
import 'package:chitchat/features/reels/presentation/screens/upload_long_video_screen.dart';
import 'package:chitchat/features/search/presentation/screens/search_screen.dart';

import '../../../profile/presentation/screens/user_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const SizedBox.shrink(), // Placeholder for Post button
    const ReelsFeedScreen(),
    const UserProfileScreen(),
  ];

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 380.h,
        borderRadius: 30.r,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F0F0F).withOpacity(0.9),
            const Color(0xFF0F0F0F).withOpacity(0.8),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryNeon.withOpacity(0.5),
            AppColors.secondaryNeon.withOpacity(0.5),
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
            SizedBox(height: 32.h),
            Text(
              "Create Content",
              style: GoogleFonts.orbitron(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 40.h),
            _buildPostOptionItem(
              context,
              icon: Iconsax.video_play_copy,
              title: "Upload Reel",
              subtitle: "Short, catchy vertical videos",
              color: AppColors.primaryNeon,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadReelScreen()),
                );
              },
            ),
            SizedBox(height: 20.h),
            _buildPostOptionItem(
              context,
              icon: Iconsax.video_vertical_copy,
              title: "Upload Long Video",
              subtitle: "Full-length cinematic content",
              color: AppColors.secondaryNeon,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadLongVideoScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: color, size: 26.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16.sp),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Persistant Particle Background
          const ParticleBackground(),
          
          // 3. Page Content
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          
          // 4. Premium Bottom Bar (Full Width & High Contrast)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A).withOpacity(0.95),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SalomonBottomBar(
                  currentIndex: _currentIndex,
                  onTap: (i) {
                    if (i == 2) {
                      _showPostOptions(context);
                    } else {
                      setState(() => _currentIndex = i);
                    }
                  },
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                  unselectedItemColor: Colors.white54,
                  items: [
                    _buildNavItem(Iconsax.home_1_copy, "Home", AppColors.primaryNeon),
                    _buildNavItem(Iconsax.search_normal_1_copy, "Explore", AppColors.secondaryNeon),
                    _buildNavItem(Iconsax.add_square_copy, "Post", Colors.white),
                    _buildNavItem(Iconsax.video_play_copy, "Reels", AppColors.success),
                    _buildNavItem(Iconsax.user_copy, "Profile", Colors.amber),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SalomonBottomBarItem _buildNavItem(IconData icon, String title, Color color) {
    return SalomonBottomBarItem(
      icon: Icon(icon, size: 22.sp),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12.sp),
      ),
      selectedColor: color,
      unselectedColor: Colors.white54,
    );
  }
}
