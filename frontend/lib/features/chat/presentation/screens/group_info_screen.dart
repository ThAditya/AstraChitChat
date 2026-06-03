import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/chat_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chitchat/core/providers/premium_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/core/router/app_router.dart';

class GroupInfoScreen extends ConsumerWidget {
  final ChatModel chat;

  const GroupInfoScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = chat.members ?? [];
    final isPremium = ref.watch(isPremiumProvider);
    final visibleMembers = isPremium ? members : members.take(2).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Iconsax.arrow_left_2_copy, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                chat.name,
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: chat.avatar,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.surface),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surface,
                      child: Icon(Iconsax.people_copy, size: 50.sp, color: AppColors.textGrey),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withOpacity(0.8),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: GoogleFonts.inter(
                      color: AppColors.primaryNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Official group for ${chat.name}. Discussion about project and updates.",
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${members.length} Members",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      if (isPremium)
                        Icon(Iconsax.user_add_copy, color: AppColors.primaryNeon, size: 20.sp),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final member = visibleMembers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surface,
                    backgroundImage: CachedNetworkImageProvider(member.avatar),
                  ),
                  title: Text(
                    member.name,
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  trailing: member.role == 'admin' 
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryNeon),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "Admin",
                          style: TextStyle(color: AppColors.primaryNeon, fontSize: 10.sp),
                        ),
                      )
                    : null,
                );
              },
              childCount: visibleMembers.length,
            ),
          ),
          if (!isPremium && members.length > 2)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: GestureDetector(
                  onTap: () => context.push(AppRouter.premium),
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryNeon.withOpacity(0.1), AppColors.secondaryNeon.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.primaryNeon.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.crown_1_copy, color: AppColors.primaryNeon, size: 24.sp),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "See all members",
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Unlock with Chit Chat Premium",
                                style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16.sp),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  _buildDangerOption(Iconsax.logout_copy, "Exit Group"),
                  _buildDangerOption(Iconsax.dislike_copy, "Report Group"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent, size: 22.sp),
      title: Text(
        title,
        style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
