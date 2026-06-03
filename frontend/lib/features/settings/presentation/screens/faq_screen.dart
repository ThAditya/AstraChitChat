import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'q': 'Is Chit Chat end-to-end encrypted?',
      'a': 'Yes, all personal chats and calls are secured with industry-standard end-to-end encryption.'
    },
    {
      'q': 'How do I upgrade to Premium?',
      'a': 'Go to Settings > Get Chit Chat Premium to see our subscription plans and unlock exclusive features.'
    },
    {
      'q': 'Can I use one account on multiple devices?',
      'a': 'Premium members can use Chit Chat on up to 3 mobile devices simultaneously.'
    },
    {
      'q': 'How do I report a bug?',
      'a': 'You can use the "Report a Problem" option in the Help & Support section or contact us directly at support@chitchat.com.'
    },
    {
      'q': 'Are my reels public?',
      'a': 'By default, reels are public. You can change your account privacy in Settings > Privacy & Security.'
    },
  ];

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
          'FAQ',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  iconColor: AppColors.primaryNeon,
                  collapsedIconColor: Colors.white54,
                  title: Text(
                    faqs[index]['q']!,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: Text(
                        faqs[index]['a']!,
                        style: GoogleFonts.inter(
                          color: AppColors.textGrey,
                          fontSize: 13.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 100).ms).slideX();
            },
          ),
        ],
      ),
    );
  }
}
