import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../providers/social_providers.dart';
import '../../domain/models/social_models.dart';
import '../widgets/member_selector.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _createGroup() {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final members = ref.read(selectedMembersProvider);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member')),
      );
      return;
    }

    final newGroup = GroupModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: desc,
      members: members,
      createdAt: DateTime.now(),
    );

    ref.read(groupsProvider.notifier).addGroup(newGroup);
    
    // Reset selection
    ref.read(selectedMembersProvider.notifier).state = [];
    
    // Redirect to list (using a placeholder for now if not exists, but I'll create it)
    context.pushReplacement('/groups-list');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            ref.read(selectedMembersProvider.notifier).state = [];
            context.pop();
          },
        ),
        title: Text(
          'New Group',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: AppColors.surface,
                        child: Icon(Iconsax.camera_copy, color: AppColors.textGrey, size: 30.sp),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: const BoxDecoration(color: AppColors.primaryNeon, shape: BoxShape.circle),
                          child: const Icon(Iconsax.add_copy, size: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Group Name',
                    hintStyle: TextStyle(color: AppColors.textGrey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryNeon)),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: _descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(color: AppColors.textGrey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryNeon)),
                  ),
                ),
                SizedBox(height: 40.h),
                const MemberSelector(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createGroup,
        backgroundColor: AppColors.primaryNeon,
        icon: const Icon(Icons.check, color: Colors.black),
        label: Text('CREATE', style: GoogleFonts.orbitron(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
