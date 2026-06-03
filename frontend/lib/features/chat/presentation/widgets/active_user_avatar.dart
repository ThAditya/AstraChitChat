import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/router/app_router.dart';
import 'package:chitchat/features/chat/domain/models/chat_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ActiveUserAvatar extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback? onStoryTap;

  const ActiveUserAvatar({super.key, required this.chat, this.onStoryTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (chat.hasStory && onStoryTap != null) {
          onStoryTap!();
        } else {
          context.push(AppRouter.chatDetail, extra: chat);
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Stack(
              children: [
                // Story border (Gradient for stories, transparent otherwise)
                Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: chat.hasStory ? LinearGradient(
                      colors: [
                        AppColors.primaryNeon,
                        AppColors.secondaryNeon.withOpacity(0.8),
                      ],
                    ) : null,
                    border: !chat.hasStory ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundColor: AppColors.surface,
                      backgroundImage: chat.avatar.isNotEmpty 
                          ? CachedNetworkImageProvider(chat.avatar) 
                          : null,
                      child: chat.avatar.isEmpty 
                          ? const Icon(Iconsax.user_copy, color: Colors.white) 
                          : null,
                    ),
                  ),
                ),
                // Online indicator - Only show if isOnline is true
                if (chat.isOnline)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 14.r,
                      height: 14.r,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              chat.name.split(' ')[0],
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8));
  }
}
