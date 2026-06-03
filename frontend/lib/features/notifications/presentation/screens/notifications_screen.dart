import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../../domain/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  final NotificationType? filterType;
  const NotificationsScreen({super.key, this.filterType});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NotificationItem> _notifications = List.from(mockNotifications);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.filterType != null ? 1 : 5, 
      vsync: this
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((element) => element.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.filter_edit_copy, color: Colors.white),
          ),
          TextButton(
            onPressed: () => setState(() => _notifications.clear()),
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(
                color: AppColors.secondaryNeon,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          Column(
            children: [
              if (widget.filterType == null) _buildCategoryTabs(),
              Expanded(
                child: widget.filterType != null
                    ? _buildNotificationList(widget.filterType)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildNotificationList(null), // All
                          _buildNotificationList(NotificationType.message),
                          _buildNotificationList(null, isSocial: true),
                          _buildNotificationList(NotificationType.call),
                          _buildNotificationList(NotificationType.system),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 45.h,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.secondaryNeon,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGrey,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Messages'),
          Tab(text: 'Social'),
          Tab(text: 'Calls'),
          Tab(text: 'System'),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildNotificationList(NotificationType? filterType, {bool isSocial = false}) {
    final filteredList = _notifications.where((n) {
      if (filterType != null) return n.type == filterType;
      if (isSocial) {
        return n.type == NotificationType.like ||
            n.type == NotificationType.comment ||
            n.type == NotificationType.follow ||
            n.type == NotificationType.mention;
      }
      return true;
    }).toList();

    if (filteredList.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final notification = filteredList[index];
        return _buildNotificationItem(notification, index);
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, int index) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Iconsax.trash_copy, color: AppColors.error, size: 24.sp),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white.withOpacity(0.02) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: notification.isRead ? Colors.white.withOpacity(0.05) : AppColors.secondaryNeon.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: CachedNetworkImageProvider(notification.userAvatar),
                ),
                if (notification.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white),
                      children: [
                        TextSpan(
                          text: '${notification.userName} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: notification.actionText,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        notification.timeAgo,
                        style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textGrey),
                      ),
                      if (!notification.isRead) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryNeon,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (notification.type == NotificationType.message) ...[
                    SizedBox(height: 8.h),
                    _buildActionButton('Reply', Iconsax.send_1_copy, () {}),
                  ],
                  if (notification.type == NotificationType.call) ...[
                    SizedBox(height: 8.h),
                    _buildActionButton('Call Back', Iconsax.call_calling_copy, () {}),
                  ],
                ],
              ),
            ),

            // Preview image or icon
            if (notification.previewImage != null)
              Container(
                width: 45.r,
                height: 45.r,
                margin: EdgeInsets.only(left: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(notification.previewImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              _buildTypeIcon(notification.type),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.secondaryNeon.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.secondaryNeon.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.secondaryNeon, size: 14.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.secondaryNeon,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.follow:
        icon = Iconsax.user_add_copy;
        color = AppColors.primaryNeon;
        break;
      case NotificationType.comment:
        icon = Iconsax.message_text_copy;
        color = AppColors.success;
        break;
      case NotificationType.mention:
        icon = Iconsax.direct_notification_copy;
        color = Colors.amber;
        break;
      case NotificationType.system:
        icon = Iconsax.security_safe_copy;
        color = AppColors.error;
        break;
      case NotificationType.video:
        icon = Iconsax.video_play_copy;
        color = AppColors.secondaryNeon;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 16.sp),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.notification_status_copy, color: AppColors.textGrey, size: 80.sp)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
          SizedBox(height: 20.h),
          Text(
            'No notifications yet',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'We will notify you when something happens',
            style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
