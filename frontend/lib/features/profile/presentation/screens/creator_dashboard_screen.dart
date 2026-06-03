import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';
import 'package:chitchat/features/reels/presentation/screens/upload_reel_screen.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Creator Overview', 'Last 30 days'),
                      SizedBox(height: 16.h),
                      _buildOverviewGrid().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                      SizedBox(height: 32.h),
                      
                      _buildSectionHeader('Analytics', 'Performance growth'),
                      SizedBox(height: 16.h),
                      _buildAnalyticsCard().animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
                      SizedBox(height: 32.h),

                      _buildSectionHeader('Story Insights', 'Last 24 hours'),
                      SizedBox(height: 16.h),
                      _buildStoryInsights(),
                      SizedBox(height: 32.h),

                      _buildSectionHeader('Content Management', 'Recent uploads'),
                      SizedBox(height: 16.h),
                      _buildContentList().animate().fadeIn(delay: 400.ms),
                      SizedBox(height: 32.h),

                      _buildSectionHeader('Audience Insights', 'Demographics'),
                      SizedBox(height: 16.h),
                      _buildAudienceGrid().animate().fadeIn(delay: 500.ms),
                      SizedBox(height: 32.h),

                      _buildSectionHeader('Monetization', 'Revenue & Status'),
                      SizedBox(height: 16.h),
                      _buildMonetizationCard().animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
                      SizedBox(height: 32.h),

                      _buildSectionHeader('Creator Tools', 'Quick Actions'),
                      SizedBox(height: 16.h),
                      _buildToolsGrid().animate().fadeIn(delay: 700.ms),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      backgroundColor: AppColors.background.withValues(alpha: 0.8),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
        title: Text(
          'Creator Studio',
          style: GoogleFonts.orbitron(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.notification_copy, color: Colors.white),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        Text(
          'View all',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: const Color(0xFF6366F1),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard('Total Followers', '124.5K', '+12%', Iconsax.user_copy, const Color(0xFF6366F1)),
        _buildStatCard('Total Views', '2.8M', '+18%', Iconsax.eye_copy, const Color(0xFFA855F7)),
        _buildStatCard('Total Likes', '850K', '+5%', Iconsax.heart_copy, const Color(0xFFEC4899)),
        _buildStatCard('Profile Visits', '42.1K', '+24%', Iconsax.profile_2user_copy, const Color(0xFF06B6D4)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String trend, IconData icon, Color accentColor) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 16.r,
      blur: 20,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: accentColor, size: 16.sp),
                ),
                Text(
                  trend,
                  style: GoogleFonts.inter(
                    color: AppColors.success,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 220.h,
      borderRadius: 20.r,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
      ),
      borderGradient: LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAnalyticsSmallStat('Engagement Rate', '4.8%', '+0.5%'),
                _buildAnalyticsSmallStat('Watch Time', '12.4K hrs', '+8%'),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 120.h,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 1),
                        const FlSpot(2, 4),
                        const FlSpot(3, 2),
                        const FlSpot(4, 5),
                        const FlSpot(5, 3),
                        const FlSpot(6, 4),
                      ],
                      isCurved: true,
                      color: const Color(0xFF6366F1),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withValues(alpha: 0.3),
                            const Color(0xFF6366F1).withValues(alpha: 0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSmallStat(String label, String value, String trend) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textGrey),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.orbitron(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(width: 4.w),
            Text(
              trend,
              style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoryInsights() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          final views = ['12.4K', '8.2K', '15.1K', '9.4K'];
          final times = ['2h ago', '5h ago', '12h ago', '20h ago'];
          return Container(
            width: 90.w,
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/story_insight_$index/200/400'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.eye_copy, size: 10.sp, color: AppColors.primaryNeon),
                      SizedBox(width: 4.w),
                      Text(
                        views[index],
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    times[index],
                    style: GoogleFonts.inter(
                      fontSize: 8.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentList() {
    return Column(
      children: List.generate(3, (index) => _buildContentItem(index)),
    );
  }

  Widget _buildContentItem(int index) {
    final titles = ['My New Travel Reel', 'Coding Setup 2024', 'Late Night Vibes'];
    final views = ['1.2M', '450K', '890K'];
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/content_$index/200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index],
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _buildContentStat(Iconsax.eye_copy, views[index]),
                    SizedBox(width: 12.w),
                    _buildContentStat(Iconsax.heart_copy, '12K'),
                    SizedBox(width: 12.w),
                    _buildContentStat(Iconsax.message_copy, '245'),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: AppColors.textGrey, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildContentStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textGrey, size: 12.sp),
        SizedBox(width: 4.w),
        Text(
          value,
          style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildAudienceGrid() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 180.h,
      borderRadius: 20.r,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
      ),
      borderGradient: LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top Countries', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12.h),
                  _buildDemographicBar('USA', 0.8, const Color(0xFF6366F1)),
                  _buildDemographicBar('India', 0.6, const Color(0xFFA855F7)),
                  _buildDemographicBar('UK', 0.4, const Color(0xFFEC4899)),
                ],
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Returning', style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textGrey)),
                  Text('64%', style: GoogleFonts.orbitron(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.success)),
                  Text('Viewers', style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicBar(String country, double percent, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(country, style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textGrey)),
              Text('${(percent * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white70)),
            ],
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonetizationCard() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 140.h,
      borderRadius: 20.r,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          const Color(0xFF6366F1).withValues(alpha: 0.1),
          const Color(0xFFA855F7).withValues(alpha: 0.05)
        ],
      ),
      borderGradient: LinearGradient(
        colors: [const Color(0xFF6366F1).withValues(alpha: 0.3), Colors.transparent],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Estimated Earnings', style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textGrey)),
                  SizedBox(height: 4.h),
                  Text('\$12,450.00', style: GoogleFonts.orbitron(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('Monetized', style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.success, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.wallet_3_copy, color: const Color(0xFF6366F1), size: 32.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid() {
    final tools = [
      {'name': 'Upload Reel', 'icon': Iconsax.video_play_copy, 'color': const Color(0xFF6366F1)},
      {'name': 'Upload Video', 'icon': Iconsax.video_circle_copy, 'color': const Color(0xFFA855F7)},
      {'name': 'Go Live', 'icon': Iconsax.flash_1_copy, 'color': const Color(0xFFEC4899)},
      {'name': 'Analytics', 'icon': Iconsax.chart_1_copy, 'color': const Color(0xFF06B6D4)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 2.5,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return GestureDetector(
          onTap: () {
            if (tool['name'] == 'Upload Reel' || tool['name'] == 'Upload Video') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadReelScreen()),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tool['icon'] as IconData, color: tool['color'] as Color, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  tool['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
