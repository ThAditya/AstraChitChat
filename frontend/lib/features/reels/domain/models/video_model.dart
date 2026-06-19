class VideoModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String creatorName;
  final String creatorAvatar;
  final String views;
  final String uploadTime;
  final String duration;
  final bool isVerified;
  final String category;

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.creatorName,
    required this.creatorAvatar,
    required this.views,
    required this.uploadTime,
    required this.duration,
    this.isVerified = false,
    required this.category,
  });
}

final List<VideoModel> mockVideos = [
  VideoModel(
    id: 'v1',
    title: 'The Future of Neural Networks in 2025',
    thumbnailUrl: 'https://picsum.photos/seed/v1/800/450',
    creatorName: 'Tech Insider',
    creatorAvatar: 'https://i.pravatar.cc/150?u=tech',
    views: '1.2M views',
    uploadTime: '2 days ago',
    duration: '12:45',
    isVerified: true,
    category: 'Technology',
  ),
  VideoModel(
    id: 'v2',
    title: 'Modern UI Design: Glassmorphism vs Neumorphism',
    thumbnailUrl: 'https://picsum.photos/seed/v2/800/450',
    creatorName: 'Design Master',
    creatorAvatar: 'https://i.pravatar.cc/150?u=design',
    views: '850K views',
    uploadTime: '5 hours ago',
    duration: '18:20',
    category: 'Education',
  ),
  VideoModel(
    id: 'v3',
    title: 'Top 10 Hidden Gems in Cyberpunk 2077',
    thumbnailUrl: 'https://picsum.photos/seed/v3/800/450',
    creatorName: 'Gamer Pro',
    creatorAvatar: 'https://i.pravatar.cc/150?u=gamer',
    views: '2.5M views',
    uploadTime: '1 week ago',
    duration: '10:15',
    isVerified: true,
    category: 'Gaming',
  ),
  VideoModel(
    id: 'v4',
    title: 'How to Build a Billion Dollar Social Platform',
    thumbnailUrl: 'https://picsum.photos/seed/v4/800/450',
    creatorName: 'Founder Stories',
    creatorAvatar: 'https://i.pravatar.cc/150?u=founder',
    views: '150K views',
    uploadTime: '3 days ago',
    duration: '25:30',
    category: 'Business',
  ),
];

final List<String> videoCategories = [
  'All',
  'Technology',
  'Gaming',
  'Education',
  'Entertainment',
  'Podcasts',
  'News',
  'Business',
];
