import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/router/app_router.dart';
import 'package:chitchat/features/chat/domain/models/chat_model.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;

  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(chat.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {},
            backgroundColor: AppColors.primaryNeon,
            foregroundColor: Colors.white,
            icon: Iconsax.archive_1_copy,
            label: 'Archive',
          ),
          SlidableAction(
            onPressed: (_) {},
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Iconsax.volume_cross_copy,
            label: 'Mute',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {},
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Iconsax.trash_copy,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => context.push(AppRouter.chatDetail, extra: chat),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            children: [
              // Avatar with Online Indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.surface,
                    backgroundImage: chat.avatar.isNotEmpty 
                        ? CachedNetworkImageProvider(chat.avatar) 
                        : null,
                    child: chat.avatar.isEmpty 
                        ? const Icon(Iconsax.user_copy, color: Colors.white) 
                        : null,
                  ),
                  if (chat.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        width: 14.r,
                        height: 14.r,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16.w),
              // Chat Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chat.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          chat.time,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        if (chat.isTyping)
                          Text(
                            "typing...",
                            style: TextStyle(
                              color: AppColors.primaryNeon,
                              fontSize: 14.sp,
                              fontStyle: FontStyle.italic,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                           .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5))
                        else
                          Expanded(
                            child: Text(
                              chat.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        SizedBox(width: 8.w),
                        if (chat.isMuted)
                          Icon(Iconsax.volume_cross_copy, size: 14.sp, color: AppColors.textGrey),
                        if (!chat.isTyping) ...[
                          SizedBox(width: 4.w),
                          _buildStatusIcon(chat.status),
                        ],
                        if (chat.unreadCount > 0)
                          Container(
                            margin: EdgeInsets.only(left: 8.w),
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryNeon.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              chat.unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildStatusIcon(MessageStatus status) {
    IconData icon;
    Color color = AppColors.textGrey;
    
    switch (status) {
      case MessageStatus.sent:
        icon = Icons.check;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = AppColors.primaryNeon;
        break;
    }
    
    return Icon(icon, size: 16.sp, color: color);
  }
}
