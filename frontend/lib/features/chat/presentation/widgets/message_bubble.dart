import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppColors.textGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            _buildOption(Iconsax.back_square_copy, 'Reply', () => Navigator.pop(context)),
            _buildOption(Iconsax.copy_copy, 'Copy Text', () => Navigator.pop(context)),
            _buildOption(Iconsax.forward_copy, 'Forward', () => Navigator.pop(context)),
            _buildOption(Iconsax.info_circle_copy, 'Message Info', () => Navigator.pop(context)),
            _buildOption(Iconsax.trash_copy, 'Delete', () => Navigator.pop(context), isDestructive: true),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? AppColors.error : Colors.white, size: 22.sp),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: isDestructive ? AppColors.error : Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final replyTo = message.replyTo;
    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          child: Column(
            crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (replyTo != null) _buildReplyPreview(replyTo),
              if (message.isForwarded)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h, left: 4.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.forward_copy, size: 12.sp, color: AppColors.textGrey),
                      SizedBox(width: 4.w),
                      Text(
                        'Forwarded',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: AppColors.textGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: EdgeInsets.all(message.type == MessageType.image ? 4.r : 12.r),
                decoration: BoxDecoration(
                  color: message.isMe ? AppColors.primaryNeon.withOpacity(0.1) : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                    bottomLeft: Radius.circular(message.isMe ? 20.r : 4.r),
                    bottomRight: Radius.circular(message.isMe ? 4.r : 20.r),
                  ),
                  border: Border.all(
                    color: message.isMe 
                        ? AppColors.primaryNeon.withOpacity(0.2) 
                        : Colors.white.withOpacity(0.05)
                  ),
                ),
                child: _buildMessageContent(),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textGrey),
                  ),
                  if (message.isMe) ...[
                    SizedBox(width: 4.w),
                    _buildStatusIcon(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text ?? '',
          style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
        );
      case MessageType.image:
        final url = message.mediaUrl;
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: url != null 
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200.h,
                  width: double.infinity,
                  color: AppColors.surface,
                  child: Icon(Iconsax.image_copy, color: AppColors.textGrey),
                ),
              )
            : Container(
                height: 200.h,
                width: double.infinity,
                color: AppColors.surface,
                child: Icon(Iconsax.image_copy, color: AppColors.textGrey),
              ),
        );
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.play_copy, color: AppColors.primaryNeon, size: 24.sp),
            SizedBox(width: 8.w),
            Container(
              width: 100.w,
              height: 2.h,
              color: AppColors.primaryNeon.withOpacity(0.3),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 40.w,
                  height: 2.h,
                  color: AppColors.primaryNeon,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              message.duration ?? '0:00',
              style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white),
            ),
          ],
        );
      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.primaryNeon.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.document_copy, color: AppColors.primaryNeon, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  message.fileSize ?? '',
                  style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textGrey),
                ),
              ],
            ),
          ],
        );
      case MessageType.call:
        bool isMissed = message.text?.toLowerCase().contains('missed') ?? false;
        bool isVideo = message.text?.toLowerCase().contains('video') ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: (isMissed ? AppColors.error : AppColors.primaryNeon).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVideo ? Iconsax.video_copy : Iconsax.call_copy,
                color: isMissed ? AppColors.error : AppColors.primaryNeon,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text ?? 'Call',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isMissed ? 'No answer' : (message.duration ?? 'Just now'),
                  style: GoogleFonts.inter(
                    fontSize: 10.sp, 
                    color: isMissed ? AppColors.error.withOpacity(0.7) : AppColors.textGrey
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildReplyPreview(ChatMessage replyTo) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: const Border(left: BorderSide(color: AppColors.primaryNeon, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyTo.isMe ? 'You' : 'Someone',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNeon,
            ),
          ),
          Text(
            replyTo.text ?? 'Media',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sent:
        return Icon(Icons.check, size: 12.sp, color: AppColors.textGrey);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 12.sp, color: AppColors.textGrey);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 12.sp, color: AppColors.primaryNeon);
    }
  }
}
