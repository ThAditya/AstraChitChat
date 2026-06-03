import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _showSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _showSend = _controller.text.trim().isNotEmpty;
        });
      }
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Iconsax.emoji_happy_copy, color: AppColors.textGrey, size: 22.sp),
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _handleSend(),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 14.sp),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Iconsax.paperclip_copy, color: AppColors.textGrey, size: 22.sp),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Iconsax.camera_copy, color: AppColors.textGrey, size: 22.sp),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _showSend ? Iconsax.send_1_copy : Iconsax.microphone_2_copy,
                  color: Colors.black,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
