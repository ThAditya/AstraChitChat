import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../providers/social_providers.dart';

class CommunitiesListScreen extends ConsumerWidget {
  const CommunitiesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communities = ref.watch(communitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Communities',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          if (communities.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.colors_square_copy, size: 80.sp, color: AppColors.textGrey.withOpacity(0.2)),
                  SizedBox(height: 20.h),
                  Text(
                    'No Communities Yet',
                    style: GoogleFonts.orbitron(color: AppColors.textGrey, fontSize: 16.sp),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundColor: AppColors.secondaryNeon.withOpacity(0.1),
                        child: Text(
                          community.name[0].toUpperCase(),
                          style: GoogleFonts.orbitron(color: AppColors.secondaryNeon, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              community.name,
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                            Text(
                              '${community.members.length} Members',
                              style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textGrey),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-community'),
        backgroundColor: AppColors.secondaryNeon,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
