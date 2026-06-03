import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';

class UploadReelScreen extends StatefulWidget {
  const UploadReelScreen({super.key});

  @override
  State<UploadReelScreen> createState() => _UploadReelScreenState();
}

class _UploadReelScreenState extends State<UploadReelScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _allowComments = true;
  bool _allowSharing = true;
  bool _allowDownloads = false;
  String _visibility = 'Public';
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 60),
      );
      if (pickedFile != null) {
        setState(() {
          _videoFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  Future<void> _pickVideoFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null) {
        setState(() {
          _videoFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  void _simulateUpload() {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    
    // Simulate progress
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_uploadProgress < 1.0) {
        setState(() {
          _uploadProgress += 0.05;
        });
        return true;
      } else {
        setState(() {
          _isUploading = false;
        });
        _showSuccessDialog();
        return false;
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: GlassmorphicContainer(
          width: 300.w,
          height: 350.h,
          borderRadius: 32.r,
          blur: 20,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
             colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
          ),
          borderGradient: LinearGradient(
            colors: [AppColors.primaryNeon.withValues(alpha: 0.5), AppColors.secondaryNeon.withValues(alpha: 0.5)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.tick_circle_copy, color: AppColors.success, size: 60.sp),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              SizedBox(height: 24.h),
              Text(
                'Reel Published!',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Your reel is now live and secure.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14.sp),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNeon,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                ),
                child: const Text('Great'),
              ),
            ],
          ),
        ),
      ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Reel',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Preview & Upload Card
                _buildUploadCard(),
                
                SizedBox(height: 32.h),
                
                // Details Section
                _buildSectionTitle('Reel Details'),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Reel Title...',
                  icon: Iconsax.edit_2_copy,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Write a catchy description...',
                  icon: Iconsax.document_text_1_copy,
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _hashtagController,
                  hint: '#hashtags (e.g. #neon #vibes)',
                  icon: Iconsax.hashtag_copy,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _tagsController,
                  hint: 'Tags (comma separated)',
                  icon: Iconsax.tag_copy,
                ),
                
                SizedBox(height: 32.h),
                
                // Audience & Privacy
                _buildSectionTitle('Privacy Settings'),
                SizedBox(height: 16.h),
                _buildPrivacySelector(),
                
                SizedBox(height: 32.h),
                
                // Advanced Settings
                _buildSectionTitle('Advanced Settings'),
                SizedBox(height: 12.h),
                _buildToggleItem('Allow Comments', _allowComments, (v) => setState(() => _allowComments = v)),
                _buildToggleItem('Allow Sharing', _allowSharing, (v) => setState(() => _allowSharing = v)),
                _buildToggleItem('Allow Downloads', _allowDownloads, (v) => setState(() => _allowDownloads = v)),
                
                SizedBox(height: 40.h),
                
                // Action Buttons
                if (_isUploading)
                  _buildUploadProgress()
                else
                  _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Video Thumbnail Placeholder
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16.r),
                image: _videoFile != null 
                  ? null // In a real app, you'd generate a thumbnail here
                  : const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500'),
                      fit: BoxFit.cover,
                      opacity: 0.4,
                    ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_videoFile != null)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.video_tick_copy, color: AppColors.success, size: 40.sp),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            _videoFile!.path.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                          ),
                        ),
                      ],
                    )
                  else
                    Icon(Iconsax.video_play_copy, color: AppColors.primaryNeon.withValues(alpha: 0.5), size: 40.sp),
                  
                  if (_videoFile == null)
                    Positioned(
                      bottom: 8.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '0:15',
                          style: TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Selection Buttons
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUploadOption(
                  Iconsax.video_add_copy, 
                  _videoFile != null ? 'Change Video' : 'Select Video',
                  onTap: () => _pickVideoFromFile(),
                ),
                SizedBox(height: 12.h),
                _buildUploadOption(
                  Iconsax.camera_copy, 
                  'Open Camera',
                  onTap: () => _pickVideo(ImageSource.camera),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildUploadOption(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryNeon, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: AppColors.textGrey,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 14.sp),
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildPrivacySelector() {
    return Row(
      children: [
        _buildPrivacyOption('Public', Iconsax.global_copy),
        SizedBox(width: 12.w),
        _buildPrivacyOption('Followers', Iconsax.user_copy),
        SizedBox(width: 12.w),
        _buildPrivacyOption('Private', Iconsax.lock_copy),
      ],
    );
  }

  Widget _buildPrivacyOption(String label, IconData icon) {
    bool isSelected = _visibility == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _visibility = label),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryNeon.withValues(alpha: 0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryNeon : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryNeon : AppColors.textGrey, size: 20.sp),
              SizedBox(height: 4.h),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : AppColors.textGrey,
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryNeon,
            activeTrackColor: AppColors.primaryNeon.withOpacity(0.2),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            color: AppColors.primaryNeon,
            minHeight: 8.h,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Uploading: ${(_uploadProgress * 100).toInt()}%',
          style: GoogleFonts.inter(color: AppColors.primaryNeon, fontWeight: FontWeight.bold),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.textGrey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text('Draft', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: AppColors.primaryNeon.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 1),
              ],
            ),
            child: ElevatedButton(
              onPressed: _simulateUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(
                'Publish Reel',
                style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
