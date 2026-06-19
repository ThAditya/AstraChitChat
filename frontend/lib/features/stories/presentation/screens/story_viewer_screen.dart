import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/features/stories/domain/models/story_model.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentStoryIndex = 0;
  int _currentItemIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentStoryIndex);
    _progressController = AnimationController(vsync: this);
    
    _loadStory(story: widget.stories[_currentStoryIndex]);
  }

  void _loadStory({required StoryModel story, bool animateToPage = true}) {
    _progressController.stop();
    _progressController.reset();
    
    if (story.items.isEmpty) {
       // Handle empty story (like "My Story" placeholder)
       return;
    }

    _progressController.duration = const Duration(seconds: 5);
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextItem();
      }
    });
    _progressController.forward();
  }

  void _nextItem() {
    if (_currentItemIndex < widget.stories[_currentStoryIndex].items.length - 1) {
      setState(() {
        _currentItemIndex++;
      });
      _loadStory(story: widget.stories[_currentStoryIndex]);
    } else {
      _nextStory();
    }
  }

  void _previousItem() {
    if (_currentItemIndex > 0) {
      setState(() {
        _currentItemIndex--;
      });
      _loadStory(story: widget.stories[_currentStoryIndex]);
    } else {
      _previousStory();
    }
  }

  void _nextStory() {
    if (_currentStoryIndex < widget.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _currentItemIndex = 0;
      });
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _loadStory(story: widget.stories[_currentStoryIndex]);
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _currentItemIndex = 0;
      });
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _loadStory(story: widget.stories[_currentStoryIndex]);
    } else {
      Navigator.pop(context);
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
    final story = widget.stories[_currentStoryIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          _progressController.stop();
        },
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 3) {
            _previousItem();
          } else if (details.globalPosition.dx > 2 * screenWidth / 3) {
            _nextItem();
          } else {
            _progressController.forward();
          }
        },
        onLongPress: () {
          _progressController.stop();
        },
        onLongPressEnd: (_) {
          _progressController.forward();
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 500) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            // Background Image/Video
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final currentStory = widget.stories[index];
                if (currentStory.items.isEmpty) {
                  return Container(
                    color: AppColors.background,
                    child: Center(
                      child: Text(
                        "No Stories",
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  );
                }
                final item = currentStory.items[_currentItemIndex];
                return CachedNetworkImage(
                  imageUrl: item.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),

            // Top Gradient
            Container(
              height: 160.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),

            // Progress Bars
            Positioned(
              top: 60.h,
              left: 10.w,
              right: 10.w,
              child: Row(
                children: List.generate(
                  story.items.isEmpty ? 1 : story.items.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Stack(
                        children: [
                          Container(
                            height: 2.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1.r),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return Container(
                                height: 2.h,
                                width: index < _currentItemIndex
                                    ? double.infinity
                                    : index == _currentItemIndex
                                        ? MediaQuery.of(context).size.width * _progressController.value
                                        : 0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(1.r),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header Info
            Positioned(
              top: 75.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundImage: CachedNetworkImageProvider(story.creatorAvatar),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.creatorName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "2 hours ago",
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Bottom Actions
            Positioned(
              bottom: 40.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: TextField(
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: "Send reply...",
                          hintStyle: GoogleFonts.inter(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  _buildActionButton(Iconsax.heart_copy, color: Colors.white),
                  SizedBox(width: 12.w),
                  _buildActionButton(Iconsax.direct_right_copy, color: Colors.white),
                ],
              ),
            ),

            // Reactions
            Positioned(
              bottom: 110.h,
              right: 20.w,
              child: Column(
                children: [
                  _buildReactionEmoji("🔥"),
                  _buildReactionEmoji("❤️"),
                  _buildReactionEmoji("😂"),
                  _buildReactionEmoji("😮"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, {Color? color}) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Icon(icon, color: color, size: 22.sp),
    );
  }

  Widget _buildReactionEmoji(String emoji) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
    ).animate().scale(delay: 500.ms);
  }
}
