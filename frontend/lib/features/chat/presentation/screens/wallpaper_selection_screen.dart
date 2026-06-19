import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/utils/premium_snackbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';

class WallpaperSelectionScreen extends StatelessWidget {
  const WallpaperSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallpapers = [
      'https://picsum.photos/seed/wp1/800/1600',
      'https://picsum.photos/seed/wp2/800/1600',
      'https://picsum.photos/seed/wp3/800/1600',
      'https://picsum.photos/seed/wp4/800/1600',
      'https://picsum.photos/seed/wp5/800/1600',
      'https://picsum.photos/seed/wp6/800/1600',
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
          'Chat Wallpaper',
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
          GridView.builder(
            padding: EdgeInsets.all(20.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: wallpapers.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  PremiumSnackBar.show(
                    context, 
                    'Wallpaper updated successfully!',
                    icon: Iconsax.brush_copy,
                    color: AppColors.success,
                  );
                  context.pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    image: DecorationImage(
                      image: NetworkImage(wallpapers[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(12.r),
                    child: Text(
                      'Theme ${index + 1}',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (index * 100).ms).scale();
            },
          ),
        ],
      ),
    );
  }
}
