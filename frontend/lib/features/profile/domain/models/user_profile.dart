class UserProfile {
  final String id;
  final String name;
  final String username;
  final String? profilePicture;
  final String? coverPhoto;
  final String bio;
  final String location;
  final String website;
  final String category;
  final String pronouns;
  final DateTime? birthday;
  final String gender;
  final List<String> interests;
  final Map<String, String> socialLinks;
  final ProfileStats stats;
  final bool isPrivate;
  final bool isOnline;
  final bool isVerified;
  final DateTime? lastSeen;
  final bool? isFollowing;
  final bool? isBlocked;
  final bool? isMuted;

  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    this.profilePicture,
    this.coverPhoto,
    this.bio = '',
    this.location = '',
    this.website = '',
    this.category = 'Digital Creator',
    this.pronouns = '',
    this.birthday,
    this.gender = 'Prefer not to say',
    this.interests = const [],
    this.socialLinks = const {},
    required this.stats,
    this.isPrivate = false,
    this.isOnline = false,
    this.isVerified = false,
    this.lastSeen,
    this.isFollowing,
    this.isBlocked,
    this.isMuted,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? '',
      name: json['name'] ?? json['displayName'] ?? '',
      username: json['username'] ?? '',
      profilePicture: json['profilePicture'] ?? json['profilePictureUrl'],
      coverPhoto: json['coverPhoto'],
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      website: json['website'] ?? '',
      category: json['category'] ?? 'Digital Creator',
      pronouns: json['pronouns'] ?? '',
      birthday: json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      gender: json['gender'] ?? 'Prefer not to say',
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      socialLinks: (json['socialLinks'] as Map<dynamic, dynamic>?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
      stats: ProfileStats.fromJson(json['stats'] ?? {}),
      isPrivate: json['isPrivate'] ?? false,
      isOnline: json['isOnline'] ?? false,
      isVerified: json['isVerified'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.tryParse(json['lastSeen']) : null,
      isFollowing: json['isFollowing'],
      isBlocked: json['isBlocked'],
      isMuted: json['isMuted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'profilePicture': profilePicture,
      'coverPhoto': coverPhoto,
      'bio': bio,
      'location': location,
      'website': website,
      'category': category,
      'pronouns': pronouns,
      'birthday': birthday?.toIso8601String(),
      'gender': gender,
      'interests': interests,
      'socialLinks': socialLinks,
      'stats': stats.toJson(),
      'isPrivate': isPrivate,
      'isOnline': isOnline,
      'isVerified': isVerified,
      'lastSeen': lastSeen?.toIso8601String(),
      'isFollowing': isFollowing,
      'isBlocked': isBlocked,
      'isMuted': isMuted,
    };
  }
}

class ProfileStats {
  final int posts;
  final int followers;
  final int following;
  final int likes;

  ProfileStats({
    this.posts = 0,
    this.followers = 0,
    this.following = 0,
    this.likes = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      posts: json['posts'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts,
      'followers': followers,
      'following': following,
      'likes': likes,
    };
  }
}
