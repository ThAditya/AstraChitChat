class CreatorProfile {
  final String id;
  final String name;
  final String username;
  final String avatar;
  final String bio;
  final String followers;
  final String following;
  final String totalLikes;
  final bool isVerified;
  final bool isOnline;
  final String category;
  final List<String> highlights;
  final List<String> reelsThumbnails;
  final String engagementRate;
  final String totalViews;

  CreatorProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.bio,
    required this.followers,
    required this.following,
    required this.totalLikes,
    this.isVerified = false,
    this.isOnline = false,
    this.category = 'Digital Creator',
    this.highlights = const [],
    this.reelsThumbnails = const [],
    this.engagementRate = '0%',
    this.totalViews = '0',
  });
}

final mockCreatorProfile = CreatorProfile(
  id: 'elena_123',
  name: 'Elena G.',
  username: '@elena_design',
  avatar: 'https://ui-avatars.com/api/?name=Elena+G&background=FF00D6&color=fff',
  bio: 'Digital Artist | NFT Enthusiast | Exploring the boundaries of Neon Art 🎨✨\nBased in Cyber City 🌃',
  followers: '1.2M',
  following: '452',
  totalLikes: '24.5M',
  isVerified: true,
  isOnline: true,
  category: 'Visual Artist',
  engagementRate: '8.4%',
  totalViews: '150M',
  highlights: [
    'https://picsum.photos/seed/h1/200/200',
    'https://picsum.photos/seed/h2/200/200',
    'https://picsum.photos/seed/h3/200/200',
    'https://picsum.photos/seed/h4/200/200',
  ],
  reelsThumbnails: List.generate(
      12, (index) => 'https://picsum.photos/seed/reel_$index/400/800'),
);
