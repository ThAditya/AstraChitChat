class ChatPreview {
  final String name;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final String avatar;

  ChatPreview({
    required this.name,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
    required this.avatar,
  });
}

class ReelPreview {
  final String creator;
  final String views;
  final String thumbnail;

  ReelPreview({
    required this.creator,
    required this.views,
    required this.thumbnail,
  });
}

class Creator {
  final String name;
  final String bio;
  final String avatar;

  Creator({
    required this.name,
    required this.bio,
    required this.avatar,
  });
}

class VideoPreview {
  final String title;
  final String creator;
  final String views;
  final String duration;
  final String thumbnail;

  VideoPreview({
    required this.title,
    required this.creator,
    required this.views,
    required this.duration,
    required this.thumbnail,
  });
}

final List<ChatPreview> mockChats = [
  ChatPreview(name: "Alex Rivera", lastMessage: "Let's go for a shoot 📸", time: "2m ago", isOnline: true, avatar: "https://ui-avatars.com/api/?name=Alex+Rivera&background=00D1FF&color=fff"),
  ChatPreview(name: "Sarah Chen", lastMessage: "The new design is 🔥", time: "15m ago", isOnline: true, avatar: "https://ui-avatars.com/api/?name=Sarah+Chen&background=9D00FF&color=fff"),
  ChatPreview(name: "Marcus Wright", lastMessage: "Sent a voice note", time: "1h ago", avatar: "https://ui-avatars.com/api/?name=Marcus+Wright&background=00FFA3&color=fff"),
  ChatPreview(name: "Cyber Squad", lastMessage: "Meeting at 9 PM", time: "3h ago", avatar: "https://ui-avatars.com/api/?name=Cyber+Squad&background=1E1E1E&color=fff"),
];

final List<ReelPreview> mockReels = [
  ReelPreview(creator: "@neon_vibe", views: "1.2M", thumbnail: "https://picsum.photos/seed/reel1/400/800"),
  ReelPreview(creator: "@tech_guru", views: "850K", thumbnail: "https://picsum.photos/seed/reel2/400/800"),
  ReelPreview(creator: "@art_flow", views: "2.5M", thumbnail: "https://picsum.photos/seed/reel3/400/800"),
];

final List<Creator> mockCreators = [
  Creator(name: "Elena G.", bio: "Digital Artist | NFT", avatar: "https://ui-avatars.com/api/?name=Elena+G&background=FF00D6&color=fff"),
  Creator(name: "Zero 1", bio: "Tech & Innovation", avatar: "https://ui-avatars.com/api/?name=Zero+1&background=00D1FF&color=fff"),
];

final List<VideoPreview> mockVideos = [
  VideoPreview(
    title: "The Future of AI Messaging",
    creator: "Tech Insights",
    views: "1.5M views",
    duration: "12:45",
    thumbnail: "https://picsum.photos/seed/vid1/800/450",
  ),
  VideoPreview(
    title: "Building a Neon Social App",
    creator: "Code Guru",
    views: "500K views",
    duration: "25:30",
    thumbnail: "https://picsum.photos/seed/vid2/800/450",
  ),
  VideoPreview(
    title: "Design Principles 2024",
    creator: "UI Master",
    views: "2.1M views",
    duration: "08:15",
    thumbnail: "https://picsum.photos/seed/vid3/800/450",
  ),
];
