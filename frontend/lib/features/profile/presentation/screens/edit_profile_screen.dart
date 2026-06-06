import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/user_profile.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  late TextEditingController _pronounsController;
  late TextEditingController _socialLinkController;

  String _selectedGender = 'Male';
  String _selectedPlatform = 'Instagram';
  DateTime _selectedDate = DateTime(2000, 1, 1);
  bool _isPrivate = false;
  final List<String> _selectedInterests = ['Photography', 'Travel'];
  final List<String> _availableInterests = ['Photography', 'Travel', 'Tech', 'Music', 'Gaming', 'Fitness', 'Art', 'Food', 'Movies'];
  Map<String, String> _socialLinks = {};
  final FocusNode _socialLinkFocusNode = FocusNode();

  final Map<String, IconData> _platformIcons = {
    'Instagram': Iconsax.instagram_copy,
    'Twitter': Iconsax.link_2_copy,
    'GitHub': Iconsax.code_1_copy,
    'LinkedIn': Iconsax.link_copy,
    'YouTube': Iconsax.video_play_copy,
    'Facebook': Iconsax.facebook_copy,
    'Snapchat': Iconsax.ghost_copy,
    'Threads': Iconsax.link_copy,
  };

  @override
  void initState() {
    super.initState();
    final profile = ref.read(myProfileProvider).profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _websiteController = TextEditingController(text: profile?.website ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    _pronounsController = TextEditingController(text: profile?.pronouns ?? '');
    _socialLinkController = TextEditingController();
    _isPrivate = profile?.isPrivate ?? false;
    _selectedGender = profile?.gender ?? 'Male';
    _selectedDate = profile?.birthday ?? DateTime(2000, 1, 1);
    _socialLinks = profile?.socialLinks != null ? Map.from(profile!.socialLinks) : {};
    if (profile?.interests != null) {
      _selectedInterests.clear();
      _selectedInterests.addAll(profile!.interests);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _pronounsController.dispose();
    _socialLinkController.dispose();
    _socialLinkFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      await ref.read(myProfileProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        website: _websiteController.text.trim(),
        location: _locationController.text.trim(),
        pronouns: _pronounsController.text.trim(),
        isPrivate: _isPrivate,
        birthday: _selectedDate,
        gender: _selectedGender,
        interests: _selectedInterests,
        socialLinks: _socialLinks,
      );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        await ref.read(myProfileProvider.notifier).uploadProfilePicture(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickCoverPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        await ref.read(myProfileProvider.notifier).uploadCoverPhoto(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cover photo updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload cover photo: $e')),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondaryNeon,
              onPrimary: Colors.black,
              surface: AppColors.background,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(myProfileProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          profileState.isLoading
              ? const Center(child: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryNeon)),
                ))
              : TextButton(
                  onPressed: _saveProfile,
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      color: AppColors.secondaryNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
        ],
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _pickCoverPhoto,
                          child: Container(
                            height: 150.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16.r),
                              image: profileState.profile?.coverPhoto != null && profileState.profile!.coverPhoto!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(profileState.profile!.coverPhoto!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profileState.profile?.coverPhoto == null || profileState.profile!.coverPhoto!.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Iconsax.image_copy, color: Colors.white24, size: 30.sp),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'Add Cover Photo',
                                          style: GoogleFonts.inter(color: Colors.white24, fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.r),
                                        child: Icon(Iconsax.camera_copy, color: Colors.white, size: 20.sp),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 50.h),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.background, width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 50.r,
                              backgroundImage: profileState.profile?.profilePicture != null && profileState.profile!.profilePicture!.isNotEmpty
                                  ? NetworkImage(profileState.profile!.profilePicture!)
                                  : null,
                              child: profileState.profile?.profilePicture == null || profileState.profile!.profilePicture!.isEmpty
                                  ? Icon(Icons.person, size: 50.r, color: Colors.white)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryNeon,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.background, width: 2),
                                ),
                                child: Icon(Iconsax.camera_copy, color: Colors.black, size: 18.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn().scale(),
                SizedBox(height: 32.h),
                
                _buildSectionHeader('BASIC INFO'),
                _buildTextField('Full Name', _nameController, Iconsax.user_copy),
                SizedBox(height: 20.h),
                _buildTextField('Username', _usernameController, Iconsax.user_edit_copy),
                SizedBox(height: 20.h),
                _buildTextField('Pronouns', _pronounsController, Iconsax.profile_2user_copy, hint: 'e.g. he/him, they/them'),
                SizedBox(height: 20.h),
                _buildTextField('Bio', _bioController, Iconsax.document_text_copy, maxLines: 3),
                
                SizedBox(height: 32.h),
                _buildSectionHeader('PRIVATE INFO'),
                _buildGenderSelector(),
                SizedBox(height: 20.h),
                _buildDatePicker(),
                SizedBox(height: 20.h),
                _buildTextField('Location', _locationController, Iconsax.location_copy),
                SizedBox(height: 20.h),
                _buildPrivacyToggle(),

                SizedBox(height: 32.h),
                _buildSectionHeader('INTERESTS'),
                _buildInterestsSelector(),
                
                SizedBox(height: 32.h),
                _buildSectionHeader('LINKS'),
                _buildTextField('Website', _websiteController, Iconsax.link_copy),
                SizedBox(height: 20.h),
                _buildSocialLinksSection(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNeon,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppColors.textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 14.sp),
              prefixIcon: Icon(icon, color: Colors.white54, size: 20.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _availableInterests.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedInterests.remove(interest);
              } else {
                _selectedInterests.add(interest);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondaryNeon.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColors.secondaryNeon : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              interest,
              style: GoogleFonts.inter(
                color: isSelected ? AppColors.secondaryNeon : Colors.white,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppColors.textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: ['Male', 'Female', 'Other'].map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = gender),
                child: Container(
                  margin: EdgeInsets.only(right: gender == 'Other' ? 0 : 8.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondaryNeon.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? AppColors.secondaryNeon : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      gender,
                      style: GoogleFonts.inter(
                        color: isSelected ? AppColors.secondaryNeon : Colors.white,
                        fontSize: 14.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birthday',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppColors.textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar_1_copy, color: Colors.white54, size: 20.sp),
                SizedBox(width: 12.w),
                Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.white54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Links',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppColors.textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              SizedBox(width: 12.w),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: AppColors.background,
                ),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  onSelected: (newValue) {
                    setState(() {
                      _selectedPlatform = newValue;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return _platformIcons.keys.map((String value) {
                      return PopupMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(_platformIcons[value], color: Colors.white70, size: 18.sp),
                            SizedBox(width: 12.w),
                            Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp)),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  child: Row(
                    children: [
                      Icon(_platformIcons[_selectedPlatform], color: AppColors.primaryNeon, size: 18.sp),
                      Icon(Icons.arrow_drop_down, color: Colors.white54, size: 14.sp),
                    ],
                  ),
                ),
              ),
              Container(
                height: 20.h,
                width: 1,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: TextField(
                  controller: _socialLinkController,
                  focusNode: _socialLinkFocusNode,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Username or URL',
                    hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Iconsax.add_circle_copy, color: AppColors.secondaryNeon, size: 22.sp),
                onPressed: () {
                  if (_socialLinkController.text.isNotEmpty) {
                    setState(() {
                      _socialLinks[_selectedPlatform] = _socialLinkController.text.trim();
                      _socialLinkController.clear();
                    });
                    _socialLinkFocusNode.unfocus();
                  }
                },
              ),
            ],
          ),
        ),
        if (_socialLinks.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            'CONNECTED LINKS',
            style: GoogleFonts.orbitron(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNeon,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _socialLinks.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final entry = _socialLinks.entries.elementAt(index);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Icon(_platformIcons[entry.key] ?? Iconsax.link_copy, color: AppColors.primaryNeon, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            entry.value,
                            style: GoogleFonts.inter(
                              color: AppColors.textGrey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Iconsax.trash_copy, color: Colors.redAccent, size: 18.sp),
                      onPressed: () {
                        setState(() {
                          _socialLinks.remove(entry.key);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacyToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Private Account',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Only your followers can see your content',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        Switch(
          value: _isPrivate,
          onChanged: (value) => setState(() => _isPrivate = value),
          activeColor: AppColors.secondaryNeon,
        ),
      ],
    );
  }
}
