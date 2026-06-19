import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English', 'flag': '🇺🇸'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳'},
    {'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    {'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    {'name': 'German', 'native': 'Deutsch', 'flag': '🇩🇪'},
    {'name': 'Japanese', 'native': '日本語', 'flag': '🇯🇵'},
    {'name': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
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
          'Language',
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
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final lang = _languages[index];
              final isSelected = _selectedLanguage == lang['name'];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryNeon.withOpacity(0.1) : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryNeon.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: ListTile(
                  onTap: () => setState(() => _selectedLanguage = lang['name']!),
                  leading: Text(lang['flag']!, style: TextStyle(fontSize: 24.sp)),
                  title: Text(
                    lang['name']!,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    lang['native']!,
                    style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 12.sp),
                  ),
                  trailing: isSelected 
                    ? Icon(Icons.check_circle, color: AppColors.primaryNeon, size: 20.sp)
                    : null,
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideX();
            },
          ),
        ],
      ),
    );
  }
}
