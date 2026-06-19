import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chitchat/core/providers/premium_provider.dart';

class PremiumSubscriptionScreen extends ConsumerWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const ParticleBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      _buildHeader(isPremium),
                      SizedBox(height: 32.h),
                      _buildFeaturesGrid(),
                      SizedBox(height: 40.h),
                      _buildPricingComparison(),
                      SizedBox(height: 40.h),
                      _buildPricingCards(),
                      SizedBox(height: 40.h),
                      _buildSafeBadge(),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!isPremium) _buildSubscribeButton(ref),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close, color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            'Restore',
            style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 13.sp),
          ),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildHeader(bool isPremium) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(isPremium ? Iconsax.verify_copy : Iconsax.crown_1_copy, color: Colors.white, size: 40.sp),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        SizedBox(height: 24.h),
        Text(
          isPremium ? 'Premium Active' : 'Chit Chat Premium',
          style: GoogleFonts.orbitron(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          isPremium 
            ? 'Enjoy all your exclusive benefits'
            : 'Unlock the full power of secure communication',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {'title': 'Multi-Device', 'desc': 'Up to 3 mobile devices', 'icon': Iconsax.mobile_copy},
      {'title': 'Group Members', 'desc': 'View full member list', 'icon': Iconsax.people_copy},
      {'title': 'Theme Custom', 'desc': 'Change app theme', 'icon': Iconsax.brush_2_copy},
      {'title': 'Premium Badge', 'desc': 'Exclusive profile icon', 'icon': Iconsax.verify_copy},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.3,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 20.r,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(features[index]['icon'] as IconData, color: const Color(0xFF818CF8), size: 24.sp),
                SizedBox(height: 8.h),
                Text(
                  features[index]['title'] as String,
                  style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  features[index]['desc'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildPricingComparison() {
    return Column(
      children: [
        _buildComparisonRow('Mobile Devices', '1', 'Up to 3', true),
        _buildComparisonRow('View Group Members', '❌', '✅', false),
        _buildComparisonRow('Theme Change', '❌', '✅', false),
        _buildComparisonRow('Advanced Controls', '❌', '✅', false),
        _buildComparisonRow('Premium Badge', '❌', '✅', false),
      ],
    );
  }

  Widget _buildComparisonRow(String feature, String free, String premium, bool isFirst) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white60),
            ),
          ),
          Expanded(
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp, 
                color: const Color(0xFF818CF8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCards() {
    return Row(
      children: [
        Expanded(
          child: _buildPriceCard('Monthly', '\$4.99', 'per month', false),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildPriceCard('Yearly', '\$3.33', 'per month', true),
        ),
      ],
    );
  }

  Widget _buildPriceCard(String title, String price, String subtitle, bool isPopular) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFF6366F1).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isPopular ? const Color(0xFF6366F1) : Colors.white.withValues(alpha: 0.1),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'BEST VALUE',
                style: GoogleFonts.inter(fontSize: 8.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white70),
          ),
          SizedBox(height: 8.h),
          Text(
            price,
            style: GoogleFonts.orbitron(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.security_safe_copy, color: AppColors.success, size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          'Secure payment via App Store',
          style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(WidgetRef ref) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.9)],
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              ref.read(isPremiumProvider.notifier).state = true;
              ScaffoldMessenger.of(ref.context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: GlassmorphicContainer(
                    width: double.infinity,
                    height: 60.h,
                    borderRadius: 16.r,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: const LinearGradient(
                      colors: [AppColors.success, Color(0xFF00C853)],
                    ),
                    borderGradient: LinearGradient(
                      colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.verify_copy, color: Colors.white, size: 24.sp),
                        SizedBox(width: 12.w),
                        Text(
                          'Welcome to Premium Membership!',
                          style: GoogleFonts.orbitron(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            child: Text(
              'START 7-DAY FREE TRIAL',
              style: GoogleFonts.orbitron(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, delay: 500.ms),
    );
  }
}
