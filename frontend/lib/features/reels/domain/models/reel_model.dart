class ReelModel {
  final String id;
  final String creatorName;
  final String creatorAvatar;
  final String videoUrl;
  final String caption;
  final List<String> hashtags;
  final String musicName;
  final String likes;
  final String comments;
  final String shares;
  final bool isLiked;
  final bool isVerified;

  ReelModel({
    required this.id,
    required this.creatorName,
    required this.creatorAvatar,
    required this.videoUrl,
    required this.caption,
    this.hashtags = const [],
    required this.musicName,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
    this.isVerified = false,
  });
}

final List<ReelModel> mockReelsData = [
  ReelModel(
    id: '1',
    creatorName: 'alex_rivera',
    creatorAvatar: 'https://ui-avatars.com/api/?name=Alex+Rivera&background=00D1FF&color=fff',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-light-12859-large.mp4',
    caption: 'Neon vibes only! ✨ Checking out the new app design.',
    hashtags: ['#chitchat', '#neon', '#design'],
    musicName: 'Original Audio - alex_rivera',
    likes: '124K',
    comments: '1.2K',
    shares: '850',
    isLiked: true,
    isVerified: true,
  ),
  ReelModel(
    id: '2',
    creatorName: 'sarah_tech',
    creatorAvatar: 'https://ui-avatars.com/api/?name=Sarah+Chen&background=9D00FF&color=fff',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
    caption: 'Nature is the best designer. 🌸✨',
    hashtags: ['#nature', '#peace', '#aesthetic'],
    musicName: 'Nature Sounds - Sarah Chen',
    likes: '89K',
    comments: '450',
    shares: '120',
  ),
  ReelModel(
    id: '3',
    creatorName: 'cyber_squad',
    creatorAvatar: 'https://ui-avatars.com/api/?name=Cyber+Squad&background=1E1E1E&color=fff',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-digital-animation-of-a-circuit-board-1726-large.mp4',
    caption: 'Future is here. Are you ready for Chit Chat? 🚀💻',
    hashtags: ['#future', '#tech', '#coding'],
    musicName: 'Cyberpunk 2077 - Main Theme',
    likes: '256K',
    comments: '3.4K',
    shares: '5.6K',
    isVerified: true,
  ),
];
