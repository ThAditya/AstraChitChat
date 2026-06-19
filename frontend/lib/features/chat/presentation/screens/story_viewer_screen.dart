import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:chitchat/features/chat/domain/models/chat_model.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<ChatModel> chats;
  final int initialIndex;
  const StoryViewerScreen({super.key, required this.chats, required this.initialIndex});
  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;
  bool _isPopped = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextUser();
        }
      });
    _progressController.forward();
  }

  void _nextUser() {
    if (_isPopped) return;
    if (_currentIndex < widget.chats.length - 1) {
      if (mounted) {
        setState(() {
          _currentIndex++;
          _pageController.animateToPage(_currentIndex, 
            duration: const Duration(milliseconds: 400), 
            curve: Curves.easeInOut);
          _progressController.reset();
          _progressController.forward();
        });
      }
    } else {
      _closeViewer();
    }
  }

  void _previousUser() {
    if (_currentIndex > 0) {
      if (mounted) {
        setState(() {
          _currentIndex--;
          _pageController.animateToPage(_currentIndex, 
            duration: const Duration(milliseconds: 400), 
            curve: Curves.easeInOut);
          _progressController.reset();
          _progressController.forward();
        });
      }
    }
  }

  void _closeViewer() {
    if (!_isPopped && mounted) {
      _isPopped = true;
      _progressController.stop();
      context.pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chats.isEmpty) return const Scaffold(backgroundColor: Colors.black);

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.chats.length,
        itemBuilder: (context, index) {
          if (index >= widget.chats.length) return const SizedBox.shrink();
          final chat = widget.chats[index];
          
          return GestureDetector(
            onTapDown: (details) {
              final double screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 3) {
                _previousUser();
              } else if (details.globalPosition.dx > screenWidth * 2 / 3) {
                _nextUser();
              }
            },
            child: Stack(children: [
              // Story Background
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: chat.avatar,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))),
                  errorWidget: (context, url, error) => Container(color: Colors.black, child: const Icon(Icons.error, color: Colors.white)),
                ),
              ),
              Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.4)], stops: const [0.0, 0.5, 1.0])))),
              
              // Top Bar & Progress
              SafeArea(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h), child: Column(children: [
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) => Row(
                    children: List.generate(widget.chats.length, (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2.r),
                          child: LinearProgressIndicator(
                            value: i < _currentIndex ? 1.0 : (i == _currentIndex ? _progressController.value : 0.0),
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(i <= _currentIndex ? Colors.white : Colors.white.withOpacity(0.2)),
                            minHeight: 2.h,
                          ),
                        ),
                      ),
                    )),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(children: [
                  CircleAvatar(radius: 18.r, backgroundImage: NetworkImage(chat.avatar)),
                  SizedBox(width: 12.w),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(chat.name, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    Text("2 hours ago", style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.sp))
                  ]),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 28), onPressed: _closeViewer),
                ]),
              ]))),

              // Reactions
              Positioned(
                right: 16.w,
                bottom: 120.h,
                child: Column(
                  children: [
                    _buildReactionItem("🔥"),
                    SizedBox(height: 16.h),
                    _buildReactionItem("❤️", isHeart: true),
                    SizedBox(height: 16.h),
                    _buildReactionItem("😂"),
                    SizedBox(height: 16.h),
                    _buildReactionItem("😮"),
                  ],
                ),
              ),

              // Bottom Input
              Positioned(bottom: 0, left: 0, right: 0, child: SafeArea(child: Padding(padding: EdgeInsets.all(16.w), child: Row(children: [
                Expanded(child: Container(padding: EdgeInsets.symmetric(horizontal: 20.w), height: 50.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.r), border: Border.all(color: Colors.white.withOpacity(0.3)), color: Colors.white.withOpacity(0.1)), child: TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Send reply...", hintStyle: TextStyle(color: Colors.white70, fontSize: 14.sp), border: InputBorder.none)))),
                SizedBox(width: 12.w),
                _buildCircularActionButton(Icons.favorite_border),
                SizedBox(width: 12.w),
                _buildCircularActionButton(Iconsax.send_1_copy),
              ])))),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildReactionItem(String emoji, {bool isHeart = false}) {
    return Container(
      width: 45.r,
      height: 45.r,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: isHeart ? Icon(Icons.favorite, color: Colors.white.withOpacity(0.5), size: 24.sp) : Text(emoji, style: TextStyle(fontSize: 22.sp)),
    ).animate().scale(delay: 200.ms).fadeIn();
  }

  Widget _buildCircularActionButton(IconData icon) {
    return Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3)), color: Colors.white.withOpacity(0.1)), child: Icon(icon, color: Colors.white, size: 24.sp));
  }
}
