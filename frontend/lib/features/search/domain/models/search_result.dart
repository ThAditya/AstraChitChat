enum SearchResultType { user, chat, reel, video, hashtag }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final SearchResultType type;
  final bool isOnline;
  final String? extraInfo; // e.g., view count, duration, follower count

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    this.isOnline = false,
    this.extraInfo,
  });
}

final List<SearchResult> trendingSearches = [
  SearchResult(
    id: '1',
    title: '#cyberpunk2077',
    subtitle: '1.2M posts',
    imageUrl: 'https://picsum.photos/seed/trend1/200/200',
    type: SearchResultType.hashtag,
  ),
  SearchResult(
    id: '2',
    title: 'Neon Photography',
    subtitle: 'Trending in Videos',
    imageUrl: 'https://picsum.photos/seed/trend2/200/200',
    type: SearchResultType.video,
  ),
  SearchResult(
    id: '3',
    title: 'Elena G.',
    subtitle: 'Digital Artist',
    imageUrl: 'https://ui-avatars.com/api/?name=Elena+G&background=FF00D6&color=fff',
    type: SearchResultType.user,
  ),
];

final List<SearchResult> mockSearchResults = [
  // Users
  SearchResult(
    id: 'u1',
    title: 'Sarah Jenkins',
    subtitle: '@sarah_j',
    imageUrl: 'https://i.pravatar.cc/150?u=sarah',
    type: SearchResultType.user,
    isOnline: true,
  ),
  SearchResult(
    id: 'u2',
    title: 'Mike Ross',
    subtitle: '@mike_r',
    imageUrl: 'https://i.pravatar.cc/150?u=mike',
    type: SearchResultType.user,
  ),
  // Chats
  SearchResult(
    id: 'c1',
    title: 'Design Team',
    subtitle: 'Sarah: Look at this neon layout!',
    imageUrl: 'https://picsum.photos/seed/chat1/200/200',
    type: SearchResultType.chat,
  ),
  // Reels
  SearchResult(
    id: 'r1',
    title: 'City Lights',
    subtitle: '85K views',
    imageUrl: 'https://picsum.photos/seed/reel1/400/800',
    type: SearchResultType.reel,
    extraInfo: '0:15',
  ),
  SearchResult(
    id: 'r2',
    title: 'Future Beats',
    subtitle: '120K views',
    imageUrl: 'https://picsum.photos/seed/reel2/400/800',
    type: SearchResultType.reel,
    extraInfo: '0:30',
  ),
  // Videos
  SearchResult(
    id: 'v1',
    title: 'Flutter UI Masterclass',
    subtitle: 'Dev Mastery • 500K views',
    imageUrl: 'https://picsum.photos/seed/vid1/800/450',
    type: SearchResultType.video,
    extraInfo: '12:45',
  ),
  // Hashtags
  SearchResult(
    id: 'h1',
    title: '#flutterdev',
    subtitle: '450K posts',
    imageUrl: '',
    type: SearchResultType.hashtag,
  ),
];
