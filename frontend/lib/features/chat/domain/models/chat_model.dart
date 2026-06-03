enum MessageStatus { sent, delivered, read }

class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String avatar;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isTyping;
  final bool isMuted;
  final bool hasStory;
  final MessageStatus status;
  final bool isGroup;
  final List<GroupMember>? members;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatar,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
    this.isMuted = false,
    this.hasStory = false,
    this.status = MessageStatus.sent,
    this.isGroup = false,
    this.members,
  });

  ChatModel copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? avatar,
    String? time,
    int? unreadCount,
    bool? isOnline,
    bool? isTyping,
    bool? isMuted,
    bool? hasStory,
    MessageStatus? status,
    bool? isGroup,
    List<GroupMember>? members,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      avatar: avatar ?? this.avatar,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isTyping: isTyping ?? this.isTyping,
      isMuted: isMuted ?? this.isMuted,
      hasStory: hasStory ?? this.hasStory,
      status: status ?? this.status,
      isGroup: isGroup ?? this.isGroup,
      members: members ?? this.members,
    );
  }
}

class GroupMember {
  final String id;
  final String name;
  final String avatar;
  final String role; // 'admin' or 'member'
  final bool isOnline;

  GroupMember({
    required this.id,
    required this.name,
    required this.avatar,
    this.role = 'member',
    this.isOnline = false,
  });
}

final List<ChatModel> mockChats = [
  ChatModel(
    id: '1',
    name: 'Alex Rivera',
    lastMessage: 'Let\'s go for a shoot 📸',
    avatar: 'https://ui-avatars.com/api/?name=Alex+Rivera&background=00D1FF&color=fff',
    time: '2m ago',
    unreadCount: 2,
    isOnline: true,
    isTyping: true,
    hasStory: true,
    status: MessageStatus.read,
  ),
  ChatModel(
    id: '2',
    name: 'Sarah Chen',
    lastMessage: 'The new design is 🔥',
    avatar: 'https://ui-avatars.com/api/?name=Sarah+Chen&background=9D00FF&color=fff',
    time: '15m ago',
    isOnline: true,
    hasStory: true,
    status: MessageStatus.delivered,
  ),
  ChatModel(
    id: '3',
    name: 'Marcus Wright',
    lastMessage: 'Sent a voice note',
    avatar: 'https://ui-avatars.com/api/?name=Marcus+Wright&background=00FFA3&color=fff',
    time: '1h ago',
    isMuted: true,
    hasStory: false,
    status: MessageStatus.sent,
  ),
  ChatModel(
    id: '4',
    name: 'Cyber Squad',
    lastMessage: 'Meeting at 9 PM',
    avatar: 'https://ui-avatars.com/api/?name=Cyber+Squad&background=1E1E1E&color=fff',
    time: '3h ago',
    unreadCount: 5,
    hasStory: true,
    status: MessageStatus.read,
    isGroup: true,
    members: [
      GroupMember(id: '1', name: 'Alex Rivera', avatar: 'https://ui-avatars.com/api/?name=Alex+Rivera', role: 'admin'),
      GroupMember(id: '2', name: 'Sarah Chen', avatar: 'https://ui-avatars.com/api/?name=Sarah+Chen', role: 'admin'),
      GroupMember(id: '3', name: 'Marcus Wright', avatar: 'https://ui-avatars.com/api/?name=Marcus+Wright'),
      GroupMember(id: '5', name: 'Jessica Lee', avatar: 'https://ui-avatars.com/api/?name=Jessica+Lee'),
      GroupMember(id: '6', name: 'Me', avatar: 'https://ui-avatars.com/api/?name=Me'),
    ],
  ),
  ChatModel(
    id: '5',
    name: 'Jessica Lee',
    lastMessage: 'Check this out!',
    avatar: 'https://ui-avatars.com/api/?name=Jessica+Lee&background=FF00D6&color=fff',
    time: '5h ago',
    isOnline: false,
    hasStory: true,
  ),
];
