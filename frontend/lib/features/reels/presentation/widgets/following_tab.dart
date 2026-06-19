import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/video_model.dart';
import '../../domain/models/reel_model.dart';
import 'video_card.dart';

class FollowingTab extends StatelessWidget {
  const FollowingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 90.h, 20.w, 20.w),
      children: [
        // Live Creators
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildLiveCreator(context, index);
            },
          ),
        ),
        SizedBox(height: 24.h),
        
        // Section Title
        Text(
          'Recent from following',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Mixed Feed
        ...mockVideos.take(2).map((v) => VideoCard(video: v)),
        
        _buildReelPreview(mockReelsData[0]),
        
        SizedBox(height: 20.h),

        // Creator Recommendation
        _buildCreatorCard(),
        
        SizedBox(height: 20.h),
        ...mockVideos.skip(2).map((v) => VideoCard(video: v)),
      ],
    );
  }

  Widget _buildCreatorCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: const CachedNetworkImageProvider('https://i.pravatar.cc/150?u=creative'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creative Studio',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Digital Art & Motion',
                      style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Iconsax.user_add_copy, color: AppColors.primaryNeon)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Container(
                height: 120.h,
                margin: EdgeInsets.only(right: i == 2 ? 0 : 8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider('https://picsum.photos/seed/c$i/200/300'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCreator(BuildContext context, int index) {
    final List<String> names = ['Elena G.', 'Alex R.', 'Sarah C.', 'Mike J.', 'Design Hub', 'Tech Lab'];
    final avatar = 'https://i.pravatar.cc/150?u=live$index';
    final name = names[index % names.length];
    
    return GestureDetector(
      onTap: () => context.push(AppRouter.liveStream, extra: {
        'userName': name,
        'userAvatar': avatar,
      }),
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.orange, Colors.purple],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.surface,
                    backgroundImage: CachedNetworkImageProvider(avatar),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Text(
                    'LIVE',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              name,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReelPreview(ReelModel reel) {
    return Container(
      height: 250.h,
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: CachedNetworkImageProvider(reel.creatorAvatar), // Using avatar as placeholder thumbnail
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.video_play_copy, color: Colors.white, size: 20),
                SizedBox(width: 8.w),
                Text(
                  'Reel • ${reel.creatorName}',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              reel.caption,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
