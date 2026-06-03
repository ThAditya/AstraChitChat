enum NotificationType { message, like, comment, follow, mention, call, system, video }

class NotificationItem {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String actionText;
  final String timeAgo;
  final NotificationType type;
  final String? previewImage;
  final bool isRead;
  final bool isOnline;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.actionText,
    required this.timeAgo,
    required this.type,
    this.previewImage,
    this.isRead = false,
    this.isOnline = false,
  });
}

final List<NotificationItem> mockNotifications = [
  NotificationItem(
    id: '1',
    userId: 'u1',
    userName: 'Sarah Jenkins',
    userAvatar: 'https://i.pravatar.cc/150?u=sarah',
    actionText: 'sent you a message',
    timeAgo: '2m ago',
    type: NotificationType.message,
    isRead: false,
    isOnline: true,
  ),
  NotificationItem(
    id: '2',
    userId: 'u2',
    userName: 'Mike Ross',
    userAvatar: 'https://i.pravatar.cc/150?u=mike',
    actionText: 'liked your reel',
    timeAgo: '15m ago',
    type: NotificationType.like,
    previewImage: 'https://picsum.photos/seed/n1/200/200',
    isRead: false,
  ),
  NotificationItem(
    id: '3',
    userId: 'u3',
    userName: 'Elena G.',
    userAvatar: 'https://ui-avatars.com/api/?name=Elena+G&background=FF00D6&color=fff',
    actionText: 'started following you',
    timeAgo: '1h ago',
    type: NotificationType.follow,
    isRead: true,
  ),
  NotificationItem(
    id: '4',
    userId: 'u4',
    userName: 'Design Team',
    userAvatar: 'https://picsum.photos/seed/team/200/200',
    actionText: 'mentioned you in a comment',
    timeAgo: '3h ago',
    type: NotificationType.mention,
    isRead: true,
  ),
  NotificationItem(
    id: '5',
    userId: 'u5',
    userName: 'Alex Rivera',
    userAvatar: 'https://i.pravatar.cc/300?u=alex',
    actionText: 'Missed video call',
    timeAgo: '5h ago',
    type: NotificationType.call,
    isRead: true,
  ),
  NotificationItem(
    id: '6',
    userId: 'system',
    userName: 'Security Alert',
    userAvatar: 'https://cdn-icons-png.flaticon.com/512/1055/1055644.png',
    actionText: 'New login detected from Chrome on Windows',
    timeAgo: '1d ago',
    type: NotificationType.system,
    isRead: true,
  ),
  NotificationItem(
    id: '7',
    userId: 'u6',
    userName: 'Tech Insider',
    userAvatar: 'https://i.pravatar.cc/150?u=tech',
    actionText: 'uploaded a new video: The Future of AI',
    timeAgo: '10m ago',
    type: NotificationType.video,
    previewImage: 'https://picsum.photos/seed/v1/400/225',
    isRead: false,
  ),
  NotificationItem(
    id: '8',
    userId: 'u7',
    userName: 'Gamer Pro',
    userAvatar: 'https://i.pravatar.cc/150?u=gamer',
    actionText: 'is live: Cyberpunk 2077 Walkthrough',
    timeAgo: '1h ago',
    type: NotificationType.video,
    previewImage: 'https://picsum.photos/seed/v3/400/225',
    isRead: false,
  ),
];
