import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = [
      {'name': 'Alex Rivera', 'handle': '@alex_r', 'avatar': 'https://i.pravatar.cc/150?u=alex', 'active': true},
      {'name': 'Rivera Designs', 'handle': '@rivera_pro', 'avatar': 'https://i.pravatar.cc/150?u=rivera', 'active': false},
    ];

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
          'Switch Accounts',
          style: GoogleFonts.orbitron(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: accounts.length + 1,
            itemBuilder: (context, index) {
              if (index == accounts.length) {
                return Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: ListTile(
                    onTap: () {},
                    leading: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Iconsax.add_copy, color: AppColors.primaryNeon, size: 24.sp),
                    ),
                    title: Text('Add New Account', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ).animate().fadeIn(delay: 200.ms);
              }

              final acc = accounts[index];
              final isActive = acc['active'] as bool;

              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryNeon.withOpacity(0.05) : AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isActive ? AppColors.primaryNeon.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: ListTile(
                  onTap: () => context.pop(),
                  contentPadding: EdgeInsets.all(16.r),
                  leading: CircleAvatar(
                    radius: 25.r,
                    backgroundImage: NetworkImage(acc['avatar'] as String),
                  ),
                  title: Text(acc['name'] as String, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(acc['handle'] as String, style: GoogleFonts.inter(color: AppColors.textGrey)),
                  trailing: isActive 
                    ? Icon(Icons.check_circle_rounded, color: AppColors.primaryNeon, size: 24.sp)
                    : null,
                ),
              ).animate().fadeIn(delay: (index * 100).ms).slideX();
            },
          ),
        ],
      ),
    );
  }
}
