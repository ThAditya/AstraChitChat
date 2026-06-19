import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/models/onboarding_item.dart';
import '../widgets/glass_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Particle Background for depth
          const ParticleBackground(),

          // 2. Animated Background Glows that follow the page color
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.7, -0.6),
                radius: 1.2,
                colors: [
                  onboardingData[_currentPage].gradient.first.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 3. Skip Button
          Positioned(
            top: 50.h,
            right: 20.w,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _currentPage == onboardingData.length - 1 ? 0.0 : 1.0,
              child: TextButton(
                onPressed: () {
                  _pageController.animateToPage(
                    onboardingData.length - 1,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.fastOutSlowIn,
                  );
                },
                child: Text(
                  'SKIP',
                  style: GoogleFonts.orbitron(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),

          // 4. Main Swiper
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              final item = onboardingData[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 100.h), // Add top spacing for skip button
                        // Large Animated Icon / Illustration Placeholder
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - value) * 50),
                              child: Opacity(
                                opacity: value,
                                child: Container(
                                  height: 280.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: item.gradient.first.withOpacity(0.2),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: item.gradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Icon(
                                      item.icon,
                                      size: 180.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: 60.h),
                        
                        // Glassmorphic Content Card
                        GlassCard(
                          height: 260.h,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                            child: Column(
                              children: [
                                Text(
                                  item.title.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 120.h), // Add bottom spacing for nav bar
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // 5. Bottom Navigation Bar
          Positioned(
            bottom: 50.h,
            left: 24.w,
            right: 24.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                SmoothPageIndicator(
                  controller: _pageController,
                  count: onboardingData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: onboardingData[_currentPage].gradient.first,
                    dotColor: AppColors.textGrey.withOpacity(0.3),
                    dotHeight: 6.h,
                    dotWidth: 6.w,
                    expansionFactor: 4,
                    spacing: 8,
                  ),
                ),
                
                // Action Button
                GestureDetector(
                  onTap: () {
                    if (_currentPage < onboardingData.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                      );
                    } else {
                      context.go(AppRouter.login);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: EdgeInsets.symmetric(
                      horizontal: _currentPage == onboardingData.length - 1 ? 30.w : 20.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: onboardingData[_currentPage].gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: onboardingData[_currentPage].gradient.first.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == onboardingData.length - 1 ? 'GET STARTED' : 'NEXT',
                          style: GoogleFonts.orbitron(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                        if (_currentPage != onboardingData.length - 1) ...[
                          SizedBox(width: 8.w),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                        ],
                      ],
                    ),
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
