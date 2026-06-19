import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/utils/premium_snackbar.dart';
import 'package:chitchat/core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Help & Support',
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
          SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildSupportCard(
                  Iconsax.message_question_copy,
                  'FAQ',
                  'Find answers to common questions',
                  onTap: () => context.push(AppRouter.faq),
                ),
                _buildSupportCard(
                  Iconsax.message_text_copy,
                  'Contact Us',
                  'Chat with our support team',
                  onTap: () => context.push(AppRouter.reportProblem),
                ),
                _buildSupportCard(
                  Iconsax.security_safe_copy,
                  'Privacy Policy',
                  'How we protect your data',
                  onTap: () => context.push(AppRouter.privacyPolicy),
                ),
                _buildSupportCard(
                  Iconsax.document_text_copy,
                  'Terms of Service',
                  'Rules of the platform',
                  onTap: () => context.push(AppRouter.privacyPolicy),
                ),
                _buildSupportCard(
                  Iconsax.award_copy,
                  'About App',
                  'Version information & developer info',
                  onTap: () => context.push(AppRouter.about),
                ),
                SizedBox(height: 40.h),
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Still need help?',
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Our team is available 24/7 to assist you.',
                        style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 13.sp),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () {
                          PremiumSnackBar.show(
                            context, 
                            'Message sent! Our team will contact you soon.',
                            icon: Iconsax.message_tick_copy,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNeon,
                          foregroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('SEND A MESSAGE', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.r),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.primaryNeon.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.primaryNeon, size: 24.sp),
        ),
        title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 12.sp)),
        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 14.sp),
        onTap: onTap,
      ),
    ).animate().fadeIn().slideX();
  }
}
