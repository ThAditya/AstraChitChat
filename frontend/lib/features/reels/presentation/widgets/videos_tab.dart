import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/models/video_model.dart';
import 'package:chitchat/features/notifications/domain/models/notification_model.dart';
import 'video_card.dart';

class VideosTab extends StatefulWidget {
  const VideosTab({super.key});

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> {
  String _selectedCategory = 'All';

  List<VideoModel> get _filteredVideos {
    if (_selectedCategory == 'All') return mockVideos;
    return mockVideos.where((v) => v.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 70.h), // Spacing for floating top navigation
        // YouTube Style Top Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Row(
            children: [
              Text(
                'Videos',
                style: GoogleFonts.orbitron(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {}, 
                icon: const Icon(Icons.cast, color: Colors.white, size: 22)
              ),
              IconButton(
                onPressed: () => context.push(AppRouter.notifications, extra: NotificationType.video),
                icon: const Icon(Iconsax.notification_copy, color: Colors.white, size: 22)
              ),
              IconButton(
                onPressed: () => context.push(AppRouter.videoSearch), 
                icon: const Icon(Iconsax.search_normal_copy, color: Colors.white, size: 22)
              ),
            ],
          ),
        ),
        
        // Categories
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: videoCategories.length,
            itemBuilder: (context, index) {
              final category = videoCategories[index];
              final isSelected = _selectedCategory == category;
              return Container(
                margin: EdgeInsets.only(right: 10.w),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: Colors.white.withOpacity(0.05),
                  selectedColor: Colors.white,
                  labelStyle: GoogleFonts.inter(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),

        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              if (_selectedCategory == 'All') ...[
                // Continue Watching
                _buildSectionHeader('Continue Watching'),
                _buildContinueWatchingList(),
                SizedBox(height: 24.h),
                
                // Main Feed
                ..._filteredVideos.map((v) => VideoCard(video: v)),

                // Recommended section
                _buildSectionHeader('Recommended For You'),
                SizedBox(height: 12.h),
                ...mockVideos.reversed.map((v) => VideoCard(video: v)),
              ] else ...[
                // Filtered results
                if (_filteredVideos.isEmpty) 
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: Text(
                        'No videos found in $_selectedCategory',
                        style: GoogleFonts.inter(color: AppColors.textGrey),
                      ),
                    ),
                  )
                else
                  ..._filteredVideos.map((v) => VideoCard(video: v)),
              ],
              SizedBox(height: 100.h), // Bottom padding for navigation bar
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  Widget _buildContinueWatchingList() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 180.w,
            margin: EdgeInsets.only(right: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        'https://picsum.photos/seed/cw$index/300/180',
                        height: 90.h,
                        width: 180.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Progress Bar
                    Container(
                      height: 3.h,
                      width: 180.w * (0.3 + (index * 0.2)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'Video Title $index',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
