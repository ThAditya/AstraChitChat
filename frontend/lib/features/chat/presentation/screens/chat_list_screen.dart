import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chitchat/features/chat/presentation/providers/social_providers.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';
import 'package:chitchat/core/router/app_router.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_list_item.dart';
import 'package:chitchat/features/chat/presentation/widgets/active_user_avatar.dart';
import 'package:chitchat/features/chat/domain/models/chat_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/call_log.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ChatModel> get _filteredChats {
    final groups = ref.watch(groupsProvider);
    final communities = ref.watch(communitiesProvider);
    final userChats = ref.watch(chatsProvider);
    
    // Map Groups to ChatModel
    final groupChats = groups.map((g) {
      final name = g.name.trim().isEmpty ? "Unnamed Group" : g.name;
      final encodedName = Uri.encodeComponent(name);
      return ChatModel(
        id: g.id,
        name: name,
        lastMessage: g.description.isEmpty ? "No description" : g.description,
        avatar: g.image ?? "https://ui-avatars.com/api/?name=$encodedName&background=6366F1&color=fff",
        time: DateFormat('HH:mm').format(g.createdAt),
        isOnline: false,
        isGroup: true,
        members: g.members.map((m) => GroupMember(
          id: m.id,
          name: m.name,
          avatar: m.avatar,
          role: 'member',
          isOnline: false,
        )).toList(),
      );
    }).toList();

    // Map Communities to ChatModel
    final communityChats = communities.map((c) {
      final name = c.name.trim().isEmpty ? "Unnamed Community" : c.name;
      final encodedName = Uri.encodeComponent(name);
      return ChatModel(
        id: c.id,
        name: name,
        lastMessage: "Community: ${c.description.isEmpty ? 'No description' : c.description}",
        avatar: c.image ?? "https://ui-avatars.com/api/?name=$encodedName&background=00FFA3&color=000",
        time: DateFormat('HH:mm').format(c.createdAt),
        isOnline: false,
        isGroup: true, // Treated like a group in the chat UI
        members: c.members.map((m) => GroupMember(
          id: m.id,
          name: m.name,
          avatar: m.avatar,
          role: 'member',
          isOnline: false,
        )).toList(),
      );
    }).toList();

    final allChats = [...groupChats, ...communityChats, ...userChats];

    if (_searchQuery.isEmpty) return allChats;
    return allChats
        .where((chat) => chat.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<CallLog> get _filteredCalls {
    if (_searchQuery.isEmpty) return mockCallLogs;
    return mockCallLogs
        .where((log) => log.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const ParticleBackground(),
          
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (_isSearching || Navigator.canPop(context))
                            GestureDetector(
                              onTap: () {
                                if (_isSearching) {
                                  setState(() {
                                    _isSearching = false;
                                    _searchQuery = "";
                                    _searchController.clear();
                                  });
                                } else {
                                  context.pop();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                margin: EdgeInsets.only(right: 8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
                              ),
                            ),
                          Text(
                            _tabController.index == 0 ? "Messages" : "Calls",
                            style: GoogleFonts.orbitron(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ).animate().fadeIn().slideX(begin: -0.2),
                      Row(
                        children: [
                          _buildCircleAction(Iconsax.search_normal_1_copy, () {
                            setState(() {
                              _isSearching = !_isSearching;
                              if (!_isSearching) {
                                _searchQuery = "";
                                _searchController.clear();
                              }
                            });
                          }),
                          SizedBox(width: 12.w),
                          _buildCircleAction(Iconsax.add_square_copy, () => _showAddOptions()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TabBar(
                  controller: _tabController,
                  onTap: (index) => setState(() {}),
                  indicatorColor: AppColors.primaryNeon,
                  labelColor: AppColors.primaryNeon,
                  unselectedLabelColor: AppColors.textGrey,
                  labelStyle: GoogleFonts.orbitron(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: "CHATS"),
                    Tab(text: "CALLS"),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_isSearching)
                                  _buildSearchBar().animate().fadeIn().moveY(begin: -10),
                                if (_searchQuery.isEmpty) ...[
                                  SizedBox(height: 20.h),
                                  _buildSectionTitle("Stories"),
                                  SizedBox(height: 16.h),
                                  _buildActiveUsers(),
                                  SizedBox(height: 24.h),
                                  _buildSectionTitle("Recent Messages"),
                                ],
                              ],
                            ),
                          ),
                        ),
                        _filteredChats.isEmpty 
                        ? SliverFillRemaining(child: _buildEmptyState())
                        : SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => ChatListItem(chat: _filteredChats[index]),
                                childCount: _filteredChats.length,
                              ),
                            ),
                          ),
                        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
                      ],
                    ),
                    _buildCallsList(),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 100.h,
            right: 20.w,
            child: _buildFAB(),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNeon.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => context.push(AppRouter.aiChat),
        child: GlassmorphicContainer(
          width: 65.r,
          height: 65.r,
          borderRadius: 32.r,
          blur: 10,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [AppColors.secondaryNeon, AppColors.primaryNeon],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.5), Colors.transparent],
          ),
          child: Icon(Iconsax.magic_star_copy, color: Colors.white, size: 30.sp),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds, curve: Curves.easeInOut);
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, margin: EdgeInsets.only(bottom: 20.h), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2.r))),
            _buildMenuOption(Iconsax.magicpen_copy, "Ask AI", "Get instant help from our AI assistant", onTap: () { context.pop(); context.push(AppRouter.aiChat); }),
            _buildMenuOption(Iconsax.people_copy, "Add Group", "Create a group for multiple friends", onTap: () { context.pop(); context.push(AppRouter.createGroup); }),
            _buildMenuOption(Iconsax.colors_square_copy, "Community", "Join or create a new community", onTap: () { context.pop(); context.push(AppRouter.createCommunity); }),
            _buildMenuOption(Iconsax.brush_2_copy, "Change Wallpaper", "Customize your chat backgrounds", onTap: () { context.pop(); context.push(AppRouter.wallpaper); }),
            _buildMenuOption(Iconsax.card_send_copy, "Subscription", "Manage your premium benefits", onTap: () { context.pop(); context.push(AppRouter.premium); }),
            _buildMenuOption(Iconsax.profile_2user_copy, "List Accounts", "Switch between your profiles", onTap: () { context.pop(); context.push(AppRouter.accounts); }),
            _buildMenuOption(Iconsax.message_question_copy, "Help & Support", "Get help or report an issue", onTap: () { context.pop(); context.push(AppRouter.support); }),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(color: AppColors.primaryNeon.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)), child: Icon(icon, color: AppColors.primaryNeon, size: 22.sp)),
      title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 12.sp)),
      onTap: onTap,
    );
  }

  Widget _buildCallsList() {
    final filteredCalls = _filteredCalls;
    if (filteredCalls.isEmpty) return _buildEmptyState();
    return ListView.builder(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h), itemCount: filteredCalls.length, itemBuilder: (context, index) {
      final log = filteredCalls[index];
      return Container(margin: EdgeInsets.only(bottom: 16.h), padding: EdgeInsets.all(12.r), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Row(children: [CircleAvatar(radius: 25.r, backgroundImage: NetworkImage(log.avatar)), SizedBox(width: 16.w), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(log.name, style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)), Row(children: [Icon(log.status == CallStatus.missed ? Iconsax.call_remove_copy : (log.status == CallStatus.incoming ? Iconsax.call_received_copy : Iconsax.call_outgoing_copy), size: 14.sp, color: log.status == CallStatus.missed ? AppColors.error : AppColors.success), SizedBox(width: 4.w), Text("${log.status.name.toUpperCase()} • ${log.duration ?? ''} ${log.duration != null ? '•' : ''} Today, ${log.timestamp.hour}:${log.timestamp.minute}", style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textGrey))])])), IconButton(icon: Icon(log.type == CallType.video ? Iconsax.video_copy : Iconsax.call_copy, color: AppColors.primaryNeon, size: 20.sp), onPressed: () {
        // Create a dummy chat model for the call screen
        final model = ChatModel(
          id: index.toString(),
          name: log.name,
          avatar: log.avatar,
          lastMessage: "Call",
          time: "Now",
        );
        if (log.type == CallType.video) {
          context.push(AppRouter.videoCall, extra: model);
        } else {
          context.push(AppRouter.voiceCall, extra: model);
        }
      })]));
    });
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: GlassmorphicContainer(width: 40.r, height: 40.r, borderRadius: 12.r, blur: 10, alignment: Alignment.center, border: 1, linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]), borderGradient: LinearGradient(colors: [AppColors.primaryNeon.withOpacity(0.2), AppColors.secondaryNeon.withOpacity(0.2)]), child: Icon(icon, size: 20.sp, color: Colors.white)));
  }

  Widget _buildSearchBar() {
    return GlassmorphicContainer(width: double.infinity, height: 50.h, borderRadius: 16.r, blur: 20, alignment: Alignment.center, border: 1, linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]), borderGradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]), child: TextField(controller: _searchController, onChanged: (value) => setState(() => _searchQuery = value), style: TextStyle(color: Colors.white, fontSize: 14.sp), decoration: InputDecoration(hintText: "Search messages...", hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14.sp), prefixIcon: Icon(Iconsax.search_normal_1_copy, color: AppColors.textGrey, size: 18.sp), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.close, color: AppColors.textGrey, size: 18.sp), onPressed: () { setState(() { _searchQuery = ""; _searchController.clear(); }); }) : null, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12.h))));
  }

  Widget _buildSectionTitle(String title) { return Text(title, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textGrey, letterSpacing: 1)); }

  Widget _buildActiveUsers() {
    final activeChats = mockChats.where((c) => c.isOnline || c.hasStory).toList();
    return SizedBox(
      height: 120.h, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal, 
        clipBehavior: Clip.none,
        itemCount: activeChats.length, 
        itemBuilder: (context, index) => ActiveUserAvatar(
          chat: activeChats[index],
          onStoryTap: () {
            context.push(AppRouter.storyViewer, extra: {
              'chats': activeChats,
              'index': index,
            });
          },
        )
      )
    );
  }

  Widget _buildEmptyState() {
    bool isSearchEmpty = _searchQuery.isNotEmpty;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(isSearchEmpty ? Iconsax.user_remove_copy : Iconsax.message_notif_copy, size: 80.sp, color: AppColors.textGrey.withOpacity(0.3)), SizedBox(height: 20.h), Text(isSearchEmpty ? "Person not found" : "No messages yet", style: GoogleFonts.orbitron(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textGrey)), SizedBox(height: 8.h), Text(isSearchEmpty ? "We couldn't find anyone matching '$_searchQuery'" : "Start a conversation with your friends", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textGrey))]));
  }
}
