import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../providers/profile_provider.dart';

enum FollowListType { followers, following }

class FollowListScreen extends ConsumerStatefulWidget {
  final String userId;
  final String username;
  final FollowListType type;

  const FollowListScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.type,
  });

  @override
  ConsumerState<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends ConsumerState<FollowListScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(profileRepositoryProvider);
      final List<Map<String, dynamic>> result;
      if (widget.type == FollowListType.followers) {
        result = await repository.getFollowers(widget.userId);
      } else {
        result = await repository.getFollowing(widget.userId);
      }

      if (mounted) {
        setState(() {
          _users = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Column(
          children: [
            Text(
              widget.username,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textGrey,
              ),
            ),
            Text(
              widget.type == FollowListType.followers ? 'Followers' : 'Following',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!, style: const TextStyle(color: Colors.white)),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: _fetchUsers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _users.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.type == FollowListType.followers ? Iconsax.user_minus_copy : Iconsax.user_remove_copy,
                                size: 64.sp,
                                color: Colors.white24,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                widget.type == FollowListType.followers
                                    ? 'No followers yet'
                                    : 'Not following anyone yet',
                                style: GoogleFonts.inter(
                                  color: AppColors.textGrey,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: _users.length,
                          separatorBuilder: (context, index) => SizedBox(height: 16.h),
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _buildUserTile(user);
                          },
                        ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: user['profilePicture'] != null && user['profilePicture'].isNotEmpty
                ? NetworkImage(user['profilePicture'])
                : null,
            child: user['profilePicture'] == null || user['profilePicture'].isEmpty
                ? Icon(Iconsax.user_copy, size: 24.sp, color: Colors.white)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? '',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '@${user['username']}',
                  style: GoogleFonts.inter(
                    color: AppColors.textGrey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          // We can add a follow/unfollow button here if it's not the current user's profile
        ],
      ),
    );
  }
}
