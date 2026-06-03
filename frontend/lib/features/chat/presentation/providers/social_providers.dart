import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/social_models.dart';
import '../../domain/models/chat_model.dart';

// Dummy Users
final dummyUsersProvider = Provider<List<SocialMember>>((ref) {
  return [
    SocialMember(id: '1', name: 'Alex Rivera', avatar: 'https://ui-avatars.com/api/?name=Alex+Rivera&background=00D1FF&color=fff'),
    SocialMember(id: '2', name: 'Sarah Chen', avatar: 'https://ui-avatars.com/api/?name=Sarah+Chen&background=9D00FF&color=fff'),
    SocialMember(id: '3', name: 'Marcus Wright', avatar: 'https://ui-avatars.com/api/?name=Marcus+Wright&background=00FFA3&color=fff'),
    SocialMember(id: '4', name: 'Jessica Lee', avatar: 'https://ui-avatars.com/api/?name=Jessica+Lee&background=FF00D6&color=fff'),
    SocialMember(id: '5', name: 'Jordan Smith', avatar: 'https://ui-avatars.com/api/?name=Jordan+Smith&background=FF8C00&color=fff'),
    SocialMember(id: '6', name: 'Elena Grace', avatar: 'https://ui-avatars.com/api/?name=Elena+Grace&background=00FA9A&color=fff'),
  ];
});

// Selected Members for creation
final selectedMembersProvider = StateProvider<List<SocialMember>>((ref) => []);

// Groups Provider
class GroupsNotifier extends StateNotifier<List<GroupModel>> {
  GroupsNotifier() : super([]);

  void addGroup(GroupModel group) {
    state = [...state, group];
  }
}

final groupsProvider = StateNotifierProvider<GroupsNotifier, List<GroupModel>>((ref) {
  return GroupsNotifier();
});

// Communities Provider
class CommunitiesNotifier extends StateNotifier<List<CommunityModel>> {
  CommunitiesNotifier() : super([]);

  void addCommunity(CommunityModel community) {
    state = [...state, community];
  }
}

final communitiesProvider = StateNotifierProvider<CommunitiesNotifier, List<CommunityModel>>((ref) {
  return CommunitiesNotifier();
});

// Chats Provider
class ChatsNotifier extends StateNotifier<List<ChatModel>> {
  ChatsNotifier() : super(mockChats);

  void addChat(ChatModel chat) {
    if (!state.any((c) => c.id == chat.id)) {
      state = [chat, ...state];
    } else {
      // Move existing chat to top
      final existingChat = state.firstWhere((c) => c.id == chat.id);
      state = [existingChat, ...state.where((c) => c.id != chat.id)];
    }
  }

  void updateLastMessage(String chatId, String message, String time) {
    state = [
      for (final chat in state)
        if (chat.id == chatId)
          chat.copyWith(lastMessage: message, time: time)
        else
          chat
    ];
  }
}

final chatsProvider = StateNotifierProvider<ChatsNotifier, List<ChatModel>>((ref) {
  return ChatsNotifier();
});
