import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../../domain/models/search_result.dart';

class VideoSearchScreen extends StatefulWidget {
  const VideoSearchScreen({super.key});

  @override
  State<VideoSearchScreen> createState() => _VideoSearchScreenState();
}

class _VideoSearchScreenState extends State<VideoSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const ParticleBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: _isSearching ? _buildSearchResults() : _buildTrendingVideos(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // 1. Premium Back Button (Matches Image)
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          
          // 2. High-End Search Input (Matches Image)
          Expanded(
            child: Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(25.r), // Fully rounded pill shape
                border: Border.all(
                  color: AppColors.primaryNeon.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.video_play_copy, color: AppColors.primaryNeon, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15.sp),
                      decoration: InputDecoration(
                        hintText: 'Search videos...',
                        hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 14.sp),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_isSearching)
                    GestureDetector(
                      onTap: () => _searchController.clear(),
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, color: Colors.white70, size: 16.sp),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildTrendingVideos() {
    final videos = mockSearchResults.where((e) => e.type == SearchResultType.video).toList();
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: videos.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'Trending Videos',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return _buildVideoCard(videos[index - 1]);
      },
    );
  }

  Widget _buildSearchResults() {
    final results = mockSearchResults
        .where((e) => e.type == SearchResultType.video && 
                     e.title.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.video_play_copy, color: Colors.white24, size: 60.sp),
            SizedBox(height: 16.h),
            Text('No videos found', style: GoogleFonts.inter(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: results.length,
      itemBuilder: (context, index) => _buildVideoCard(results[index]),
    );
  }

  Widget _buildVideoCard(SearchResult item) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200.h,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200.h,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: const Icon(Iconsax.image_copy, color: Colors.white24),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(12.r),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  item.extraInfo ?? '10:00',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Icon(Icons.play_circle_fill_rounded, color: Colors.white.withOpacity(0.8), size: 50.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://i.pravatar.cc/150?u=creator',
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surface,
                      child: Icon(Iconsax.user_copy, color: Colors.white24, size: 20.sp),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${item.subtitle} • 1.2M views • 2 days ago",
                      style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
