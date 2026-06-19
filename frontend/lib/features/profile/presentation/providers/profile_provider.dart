import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/models/user_profile.dart';

final profileRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  ProfileState({this.profile, this.isLoading = false, this.error});

  ProfileState copyWith({UserProfile? profile, bool? isLoading, String? error}) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MyProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  MyProfileNotifier(this._repository) : super(ProfileState());

  Future<void> fetchMyProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.getMyProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? location,
    String? website,
    String? pronouns,
    bool? isPrivate,
    DateTime? birthday,
    String? gender,
    List<String>? interests,
    Map<String, String>? socialLinks,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedProfile = await _repository.updateProfile(
        name: name,
        username: username,
        bio: bio,
        location: location,
        website: website,
        pronouns: pronouns,
        isPrivate: isPrivate,
        birthday: birthday,
        gender: gender,
        interests: interests,
        socialLinks: socialLinks,
      );
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> uploadProfilePicture(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedProfile = await _repository.uploadProfilePicture(filePath);
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> uploadCoverPhoto(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedProfile = await _repository.uploadCoverPhoto(filePath);
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final myProfileProvider = StateNotifierProvider<MyProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return MyProfileNotifier(repository);
});

// Provider for viewing other users' profiles
final userProfileProvider = FutureProvider.family<UserProfile, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile(userId);
});
