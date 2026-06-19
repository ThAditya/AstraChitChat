import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../../domain/models/search_result.dart';
import '../../../../core/router/app_router.dart';
import '../../../chat/domain/models/chat_model.dart';
import '../../../chat/presentation/providers/social_providers.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // Update the provider query
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _quickMessage(dynamic user) {
    final chat = ChatModel(
      id: user['_id'],
      name: user['name'] ?? user['username'],
      lastMessage: "Started a chat from Explore",
      avatar: user['profilePicture'] ?? '',
      time: "Just now",
      isOnline: false, // Defaulting to false for now
    );

    ref.read(chatsProvider.notifier).addChat(chat);
    context.push(AppRouter.chatDetail, extra: chat);
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final isSearching = searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(isSearching),
            Expanded(
              child: isSearching ? _buildPeopleSearchResults() : _buildExploreGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isSearching) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // 1. Premium Back Button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          
          // 2. High-End Search Input
          Expanded(
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 50.h,
              borderRadius: 25.r, // Pill shape
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
              ),
              borderGradient: LinearGradient(
                colors: [AppColors.secondaryNeon.withValues(alpha: 0.3), Colors.transparent],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Icon(Iconsax.search_normal_copy, color: AppColors.secondaryNeon, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 15.sp),
                        decoration: InputDecoration(
                          hintText: 'Search people or categories...',
                          hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 14.sp),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (isSearching)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white70, size: 16.sp),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildExploreGrid() {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://picsum.photos/400/400?random=$index',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                if (index % 5 == 0)
                  Positioned(
                    top: 8.r,
                    right: 8.r,
                    child: Icon(Iconsax.video_play_copy, color: Colors.white, size: 16.sp),
                  ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 20).ms);
      },
    );
  }

  Widget _buildPeopleSearchResults() {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchAsync = ref.watch(searchResultsProvider);

    if (searchQuery.isEmpty) {
      return _buildExploreGrid();
    }

    return searchAsync.when(
      data: (results) {
        final users = results['users'] ?? [];

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.user_search_copy, color: Colors.white24, size: 60.sp),
                SizedBox(height: 16.h),
                Text('No people found', style: GoogleFonts.inter(color: Colors.white54)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final profilePic = user['profilePicture'];

            return ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              leading: CircleAvatar(
                radius: 25.r,
                backgroundImage: profilePic != null && profilePic.isNotEmpty
                    ? CachedNetworkImageProvider(profilePic)
                    : null,
                child: profilePic == null || profilePic.isEmpty
                    ? Icon(Iconsax.user_copy, color: Colors.white38, size: 24.sp)
                    : null,
              ),
              title: Text(
                user['username'] ?? 'User',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user['name'] ?? '',
                style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 13.sp),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Iconsax.message_copy, color: AppColors.primaryNeon, size: 20.sp),
                    onPressed: () => _quickMessage(user),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Follow',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () => context.push(AppRouter.creatorProfile, extra: user['_id']),
            ).animate().fadeIn().slideX(begin: 0.1);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
      error: (err, stack) => Center(
        child: Text('Error: $err', style: GoogleFonts.inter(color: Colors.redAccent)),
      ),
    );
  }
}
