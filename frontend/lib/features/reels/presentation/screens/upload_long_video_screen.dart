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

class UploadLongVideoScreen extends StatefulWidget {
  const UploadLongVideoScreen({super.key});

  @override
  State<UploadLongVideoScreen> createState() => _UploadLongVideoScreenState();
}

class _UploadLongVideoScreenState extends State<UploadLongVideoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  bool _allowComments = true;
  bool _allowSharing = true;
  String _visibility = 'Public';
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  File? _videoFile;
  File? _thumbnailFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
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
      debugPrint("Error picking video: $e");
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _thumbnailFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking thumbnail: $e");
    }
  }

  void _simulateUpload() {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (_uploadProgress < 1.0) {
        setState(() {
          _uploadProgress += 0.03;
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
                'Video Published!',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Your long video is now live.',
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
          'Upload Long Video',
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
                _buildVideoPreview(),
                SizedBox(height: 24.h),
                _buildThumbnailSelector(),
                SizedBox(height: 32.h),
                _buildSectionTitle('Video Details'),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Video Title',
                  icon: Iconsax.edit_2_copy,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Description',
                  icon: Iconsax.document_text_1_copy,
                  maxLines: 4,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _hashtagController,
                  hint: '#hashtags',
                  icon: Iconsax.hashtag_copy,
                ),
                SizedBox(height: 32.h),
                _buildSectionTitle('Privacy & Settings'),
                SizedBox(height: 16.h),
                _buildPrivacySelector(),
                SizedBox(height: 16.h),
                _buildToggleItem('Allow Comments', _allowComments, (v) => setState(() => _allowComments = v)),
                _buildToggleItem('Allow Sharing', _allowSharing, (v) => setState(() => _allowSharing = v)),
                SizedBox(height: 40.h),
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

  Widget _buildVideoPreview() {
    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        width: double.infinity,
        height: 180.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Center(
          child: _videoFile != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.video_tick_copy, color: AppColors.success, size: 40.sp),
                    SizedBox(height: 12.h),
                    Text(
                      _videoFile!.path.split('/').last,
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.video_add_copy, color: AppColors.primaryNeon, size: 40.sp),
                    SizedBox(height: 12.h),
                    Text(
                      'Select Video File',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildThumbnailSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thumbnail'),
        SizedBox(height: 12.h),
        Row(
          children: [
            Container(
              width: 120.w,
              height: 68.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                image: _thumbnailFile != null
                    ? DecorationImage(
                        image: FileImage(_thumbnailFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _thumbnailFile == null
                  ? const Icon(Iconsax.image_copy, color: Colors.white24)
                  : null,
            ),
            SizedBox(width: 16.w),
            TextButton.icon(
              onPressed: _pickThumbnail,
              icon: const Icon(Iconsax.add_circle_copy, color: AppColors.primaryNeon),
              label: Text(
                _thumbnailFile != null ? 'Change Thumbnail' : 'Custom Thumbnail',
                style: GoogleFonts.inter(color: AppColors.primaryNeon),
              ),
            ),
          ],
        ),
      ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _uploadProgress,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          color: AppColors.primaryNeon,
        ),
        SizedBox(height: 12.h),
        Text(
          'Uploading: ${(_uploadProgress * 100).toInt()}%',
          style: GoogleFonts.inter(color: AppColors.primaryNeon, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ElevatedButton(
        onPressed: _simulateUpload,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        child: Text(
          'Publish Video',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ),
    );
  }
}
