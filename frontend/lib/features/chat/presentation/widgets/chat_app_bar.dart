import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/chat_model.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatModel chat;

  const ChatAppBar({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Iconsax.arrow_left_2_copy, color: Colors.white, size: 20.sp),
                visualDensity: VisualDensity.compact,
              ),
              GestureDetector(
                onTap: () {
                  if (chat.isGroup) {
                    context.push(AppRouter.groupInfo, extra: chat);
                  }
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.surface,
                      backgroundImage: chat.avatar.isNotEmpty 
                          ? NetworkImage(chat.avatar) 
                          : null,
                      child: chat.avatar.isEmpty 
                          ? Icon(Iconsax.user_copy, size: 18.sp, color: Colors.white) 
                          : null,
                    ),
                    if (chat.isOnline && !chat.isGroup)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 9.r,
                          height: 9.r,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (chat.isGroup) {
                      context.push(AppRouter.groupInfo, extra: chat);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        chat.isGroup 
                            ? '${chat.members?.length ?? 0} members'
                            : (chat.isTyping 
                                ? 'typing...' 
                                : (chat.isOnline ? 'Online' : 'Last seen 2h ago')),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: chat.isTyping ? AppColors.primaryNeon : AppColors.textSecondary,
                          fontWeight: chat.isTyping ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _buildActionButton(Iconsax.video_copy, onTap: () {
                    context.push(AppRouter.videoCall, extra: chat);
                  }),
                  _buildActionButton(Iconsax.call_copy, onTap: () {
                    context.push(AppRouter.voiceCall, extra: chat);
                  }),
                  _buildActionButton(Iconsax.more_copy, onTap: () {
                    _showChatOptions(context);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            _buildMenuOption(context, Iconsax.trash_copy, "Clear Chat", Colors.white),
            _buildMenuOption(context, Iconsax.add_square_copy, "Add to List", Colors.white),
            _buildMenuOption(context, Iconsax.flag_copy, "Report", Colors.orangeAccent),
            _buildMenuOption(context, Iconsax.user_minus_copy, "Block", Colors.redAccent),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String title, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22.sp),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildActionButton(IconData icon, {required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 18.sp),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ).copyWithPadding(EdgeInsets.symmetric(horizontal: 8.w));
  }

  @override
  Size get preferredSize => Size.fromHeight(70.h);
}

extension on Widget {
  Widget copyWithPadding(EdgeInsets padding) => Padding(padding: padding, child: this);
}
