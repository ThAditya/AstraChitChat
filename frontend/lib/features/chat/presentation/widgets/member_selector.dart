import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/social_providers.dart';
import '../../domain/models/social_models.dart';

class MemberSelector extends ConsumerWidget {
  const MemberSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsers = ref.watch(dummyUsersProvider);
    final selectedMembers = ref.watch(selectedMembersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedMembers.isNotEmpty) ...[
          Text(
            'Selected (${selectedMembers.length})',
            style: GoogleFonts.inter(
              color: AppColors.primaryNeon,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedMembers.length,
              itemBuilder: (context, index) {
                final member = selectedMembers[index];
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 25.r,
                            backgroundImage: NetworkImage(member.avatar),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            member.name.split(' ')[0],
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.sp),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            ref.read(selectedMembersProvider.notifier).state = 
                                selectedMembers.where((m) => m.id != member.id).toList();
                          },
                          child: Container(
                            padding: EdgeInsets.all(2.r),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 12.sp, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
        ],
        Text(
          'All Contacts',
          style: GoogleFonts.inter(
            color: AppColors.textGrey,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allUsers.length,
          itemBuilder: (context, index) {
            final user = allUsers[index];
            final isSelected = selectedMembers.any((m) => m.id == user.id);

            void toggleSelection() {
              if (!isSelected) {
                ref.read(selectedMembersProvider.notifier).state = [...selectedMembers, user];
              } else {
                ref.read(selectedMembersProvider.notifier).state = 
                    selectedMembers.where((m) => m.id != user.id).toList();
              }
            }

            return ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: toggleSelection,
              leading: CircleAvatar(
                radius: 22.r,
                backgroundImage: NetworkImage(user.avatar),
              ),
              title: Text(
                user.name,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              trailing: Checkbox(
                value: isSelected,
                activeColor: AppColors.primaryNeon,
                checkColor: Colors.black,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                onChanged: (_) => toggleSelection(),
              ),
            );
          },
        ),
      ],
    );
  }
}
