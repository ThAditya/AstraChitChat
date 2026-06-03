enum StoryType { image, video, text, music }

class StoryModel {
  final String id;
  final String creatorName;
  final String creatorAvatar;
  final List<StoryItemModel> items;
  final bool isUnviewed;
  final bool isCloseFriend;
  final bool isLive;

  StoryModel({
    required this.id,
    required this.creatorName,
    required this.creatorAvatar,
    required this.items,
    this.isUnviewed = true,
    this.isCloseFriend = false,
    this.isLive = false,
  });
}

class StoryItemModel {
  final String id;
  final String url;
  final StoryType type;
  final DateTime timestamp;
  final String? caption;
  final String? musicTitle;
  final String? musicArtist;

  StoryItemModel({
    required this.id,
    required this.url,
    required this.type,
    required this.timestamp,
    this.caption,
    this.musicTitle,
    this.musicArtist,
  });
}

final mockStories = [
  StoryModel(
    id: '1',
    creatorName: 'Your Story',
    creatorAvatar: 'https://i.pravatar.cc/150?u=me',
    items: [],
    isUnviewed: false,
  ),
  StoryModel(
    id: '2',
    creatorName: 'Alex Rivers',
    creatorAvatar: 'https://i.pravatar.cc/150?u=alex',
    isCloseFriend: true,
    items: [
      StoryItemModel(
        id: 's1',
        url: 'https://picsum.photos/seed/s1/1080/1920',
        type: StoryType.image,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        caption: 'Morning vibes! ☕️',
      ),
      StoryItemModel(
        id: 's2',
        url: 'https://picsum.photos/seed/s2/1080/1920',
        type: StoryType.image,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  ),
  StoryModel(
    id: '3',
    creatorName: 'Elena Grace',
    creatorAvatar: 'https://i.pravatar.cc/150?u=elena',
    isLive: true,
    items: [
      StoryItemModel(
        id: 's3',
        url: 'https://picsum.photos/seed/s3/1080/1920',
        type: StoryType.image,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ],
  ),
  StoryModel(
    id: '4',
    creatorName: 'Tech Pulse',
    creatorAvatar: 'https://i.pravatar.cc/150?u=tech',
    items: [
      StoryItemModel(
        id: 's4',
        url: 'https://picsum.photos/seed/s4/1080/1920',
        type: StoryType.image,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
  ),
  StoryModel(
    id: '5',
    creatorName: 'Jordan Sky',
    creatorAvatar: 'https://i.pravatar.cc/150?u=jordan',
    items: [
      StoryItemModel(
        id: 's5',
        url: 'https://picsum.photos/seed/s5/1080/1920',
        type: StoryType.image,
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ],
  ),
];
