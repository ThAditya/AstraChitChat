import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_model.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/security_banner.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(mockMessages);
  }

  void _handleSendMessage(String text) {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(newMessage);
    });

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Mock response after 2 seconds
    if (!widget.chat.isGroup) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderId: 'other',
              text: 'Thanks for the message! (Mock response)',
              timestamp: DateTime.now(),
              status: MessageStatus.read,
            ));
          });
          _scrollToBottom();
        }
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ChatAppBar(chat: widget.chat),
      body: Stack(
        children: [
          const ParticleBackground(),
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemCount: _messages.length + 1, // +1 for security banner/date
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              const SecurityBanner().animate().fadeIn(delay: 300.ms),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 16.h),
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: Text(
                                    'TODAY',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textGrey,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(),
                            ],
                          );
                        }
                        
                        final msg = _messages[index - 1];
                        return MessageBubble(message: msg)
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: msg.isMe ? 0.2 : -0.2, curve: Curves.easeOutQuad);
                      },
                    ),
              ),
              if (widget.chat.isTyping)
                _buildTypingIndicator().animate().fadeIn(),
              MessageInput(onSend: _handleSendMessage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        children: [
          Text(
            '${widget.chat.name} is typing',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.primaryNeon,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(width: 4.w),
          _dotIndicator(0),
          _dotIndicator(1),
          _dotIndicator(2),
        ],
      ),
    );
  }

  Widget _dotIndicator(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: 4.r,
      height: 4.r,
      decoration: const BoxDecoration(
        color: AppColors.primaryNeon,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .fadeIn(delay: (index * 200).ms, duration: 600.ms)
     .then()
     .fadeOut(duration: 600.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.primaryNeon.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.message_2_copy, size: 64.sp, color: AppColors.primaryNeon),
            ),
            SizedBox(height: 24.h),
            Text(
              'Secure Chat with ${widget.chat.name}',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Start a safe conversation. Every message is encrypted and stays only between you two.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}
