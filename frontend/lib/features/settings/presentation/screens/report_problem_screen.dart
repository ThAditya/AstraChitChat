import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';
import 'package:chitchat/core/utils/premium_snackbar.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _controller = TextEditingController();
  String _selectedCategory = 'Bug';
  final List<String> _categories = ['Bug', 'Feature Request', 'Account Issue', 'Security', 'Other'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          'Report a Problem',
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
          SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What issue are you facing?',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryNeon.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryNeon : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.inter(
                            color: isSelected ? AppColors.primaryNeon : Colors.white,
                            fontSize: 12.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Describe the problem',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 8,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Please provide as much detail as possible...',
                      hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 14.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.r),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                _buildAttachmentButton(),
                SizedBox(height: 48.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        PremiumSnackBar.show(context, 'Report submitted successfully!', icon: Iconsax.tick_circle_copy);
                        context.pop();
                      } else {
                        PremiumSnackBar.show(
                          context, 
                          'Please describe the problem.', 
                          color: AppColors.error,
                          icon: Iconsax.info_circle_copy,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNeon,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text(
                      'SUBMIT REPORT',
                      style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05), style: BorderStyle.none),
      ),
      child: Row(
        children: [
          Icon(Iconsax.camera_copy, color: AppColors.primaryNeon, size: 24.sp),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Screenshot',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              Text(
                'Optional (Max 3 files)',
                style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 11.sp),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.add_circle_outline, color: Colors.white54),
        ],
      ),
    );
  }
}
