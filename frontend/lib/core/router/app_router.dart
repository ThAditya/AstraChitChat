import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_otp_screen.dart';
import '../../features/auth/presentation/screens/new_password_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/voice_call_screen.dart';
import '../../features/chat/presentation/screens/video_call_screen.dart';
import '../../features/chat/presentation/screens/ai_chat_screen.dart';
import '../../features/chat/presentation/screens/story_viewer_screen.dart';
import '../../features/chat/presentation/screens/create_group_screen.dart';
import '../../features/chat/presentation/screens/create_community_screen.dart';
import '../../features/chat/presentation/screens/wallpaper_selection_screen.dart';
import '../../features/chat/presentation/screens/account_list_screen.dart';
import '../../features/chat/presentation/screens/help_support_screen.dart';
import '../../features/chat/presentation/screens/groups_list_screen.dart';
import '../../features/chat/presentation/screens/communities_list_screen.dart';
import '../../features/chat/domain/models/chat_model.dart';
import '../../features/profile/presentation/screens/creator_profile_screen.dart';
import '../../features/profile/presentation/screens/user_profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/search/presentation/screens/video_search_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import 'package:chitchat/features/notifications/domain/models/notification_model.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_security_screen.dart';
import '../../features/settings/presentation/screens/device_management_screen.dart';
import '../../features/settings/presentation/screens/premium_subscription_screen.dart';
import '../../features/settings/presentation/screens/saved_content_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/language_settings_screen.dart';
import '../../features/settings/presentation/screens/storage_management_screen.dart';
import '../../features/settings/presentation/screens/faq_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/report_problem_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/follow_list_screen.dart';
import '../../features/reels/presentation/screens/upload_reel_screen.dart';
import '../../features/reels/presentation/screens/live_stream_screen.dart';
import '../widgets/common_placeholder_screen.dart';

import '../../features/chat/presentation/screens/group_info_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPasswordOtp = '/reset-password-otp';
  static const String newPassword = '/new-password';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String chatDetail = '/chat-detail';
  static const String groupInfo = '/group-info';
  static const String voiceCall = '/voice-call';
  static const String videoCall = '/video-call';
  static const String aiChat = '/ai-chat';
  static const String createGroup = '/create-group';
  static const String createCommunity = '/create-community';
  static const String groupsList = '/groups-list';
  static const String communitiesList = '/communities-list';
  static const String wallpaper = '/wallpaper';
  static const String accounts = '/accounts';
  static const String support = '/support';
  static const String storyViewer = '/story-viewer';
  static const String userProfile = '/user-profile';
  static const String creatorProfile = '/creator-profile';
  static const String search = '/search';
  static const String videoSearch = '/video-search';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String privacySecurity = '/privacy-security';
  static const String deviceManagement = '/device-management';
  static const String premium = '/premium';
  static const String savedContent = '/saved-content';
  static const String editProfile = '/edit-profile';
  static const String followList = '/follow-list';
  static const String notificationSettings = '/notification-settings';
  static const String languageSettings = '/language-settings';
  static const String storageManagement = '/storage-management';
  static const String faq = '/faq';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String reportProblem = '/report-problem';
  static const String uploadReel = '/upload-reel';
  static const String liveStream = '/live-stream';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: resetPasswordOtp,
        builder: (context, state) {
          final email = state.extra as String;
          return ResetPasswordOtpScreen(email: email);
        },
      ),
      GoRoute(
        path: newPassword,
        builder: (context, state) {
          final resetToken = (state.extra as Map<String, dynamic>)['resetToken'] as String;
          return NewPasswordScreen(resetToken: resetToken);
        },
      ),
      GoRoute(
        path: otp,
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? "+91 9876543210";
          return OtpVerificationScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: chat,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: chatDetail,
        builder: (context, state) {
          final chat = state.extra as ChatModel;
          return ChatScreen(chat: chat);
        },
      ),
      GoRoute(
        path: groupInfo,
        builder: (context, state) {
          final chat = state.extra as ChatModel;
          return GroupInfoScreen(chat: chat);
        },
      ),
      GoRoute(
        path: voiceCall,
        builder: (context, state) {
          final chat = state.extra as ChatModel;
          return VoiceCallScreen(chat: chat);
        },
      ),
      GoRoute(
        path: videoCall,
        builder: (context, state) {
          final chat = state.extra as ChatModel;
          return VideoCallScreen(chat: chat);
        },
      ),
      GoRoute(
        path: aiChat,
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: createGroup,
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: createCommunity,
        builder: (context, state) => const CreateCommunityScreen(),
      ),
      GoRoute(
        path: groupsList,
        builder: (context, state) => const GroupsListScreen(),
      ),
      GoRoute(
        path: communitiesList,
        builder: (context, state) => const CommunitiesListScreen(),
      ),
      GoRoute(
        path: wallpaper,
        builder: (context, state) => const WallpaperSelectionScreen(),
      ),
      GoRoute(
        path: accounts,
        builder: (context, state) => const AccountListScreen(),
      ),
      GoRoute(
        path: support,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: storyViewer,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final chats = data['chats'] as List<ChatModel>;
          final index = data['index'] as int;
          return StoryViewerScreen(chats: chats, initialIndex: index);
        },
      ),
      GoRoute(
        path: userProfile,
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: creatorProfile,
        builder: (context, state) {
          final userId = state.extra as String;
          return CreatorProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: videoSearch,
        builder: (context, state) => const VideoSearchScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) {
          final filterType = state.extra as NotificationType?;
          return NotificationsScreen(filterType: filterType);
        },
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: privacySecurity,
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: deviceManagement,
        builder: (context, state) => const DeviceManagementScreen(),
      ),
      GoRoute(
        path: premium,
        builder: (context, state) => const PremiumSubscriptionScreen(),
      ),
      GoRoute(
        path: savedContent,
        builder: (context, state) => const SavedContentScreen(),
      ),
      GoRoute(
        path: editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: followList,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return FollowListScreen(
            userId: data['userId'],
            username: data['username'],
            type: data['type'],
          );
        },
      ),
      GoRoute(
        path: notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: languageSettings,
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: storageManagement,
        builder: (context, state) => const StorageManagementScreen(),
      ),
      GoRoute(
        path: faq,
        builder: (context, state) => const FAQScreen(),
      ),
      GoRoute(
        path: about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: reportProblem,
        builder: (context, state) => const ReportProblemScreen(),
      ),
      GoRoute(
        path: uploadReel,
        builder: (context, state) => const UploadReelScreen(),
      ),
      GoRoute(
        path: liveStream,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return LiveStreamScreen(
            userName: data['userName'],
            userAvatar: data['userAvatar'],
          );
        },
      ),
      GoRoute(
        path: '/coming-soon',
        builder: (context, state) {
          final title = state.extra as String? ?? "Feature";
          return CommonPlaceholderScreen(title: title);
        },
      ),
    ],
  );
}
