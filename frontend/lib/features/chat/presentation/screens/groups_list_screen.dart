import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../providers/social_providers.dart';

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);

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
          'My Groups',
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
          if (groups.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.people_copy, size: 80.sp, color: AppColors.textGrey.withOpacity(0.2)),
                  SizedBox(height: 20.h),
                  Text(
                    'No Groups Yet',
                    style: GoogleFonts.orbitron(color: AppColors.textGrey, fontSize: 16.sp),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
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
                        backgroundColor: AppColors.primaryNeon.withOpacity(0.1),
                        child: Text(
                          group.name[0].toUpperCase(),
                          style: GoogleFonts.orbitron(color: AppColors.primaryNeon, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                            Text(
                              '${group.members.length} Members',
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
        onPressed: () => context.push('/create-group'),
        backgroundColor: AppColors.primaryNeon,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
