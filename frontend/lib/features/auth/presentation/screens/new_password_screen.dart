import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/password_input_field.dart';
import '../providers/auth_provider.dart';
import '../../../../core/router/app_router.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  final String resetToken;

  const NewPasswordScreen({super.key, required this.resetToken});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      _showSnackBar("Please enter a new password");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    try {
      await ref.read(authProvider.notifier).resetPassword(widget.resetToken, password);
      if (mounted) {
        _showSnackBar("Password reset successful!", isError: false);
        context.go(AppRouter.login);
      }
    } catch (e) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        _showSnackBar(error);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const ParticleBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Iconsax.arrow_left_1_copy, color: AppColors.textPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      padding: EdgeInsets.all(12.r),
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2),

                  SizedBox(height: 40.h),

                  Text(
                    'Create New Password',
                    style: GoogleFonts.orbitron(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  SizedBox(height: 12.h),

                  Text(
                    'Your new password must be different from previous passwords.',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  SizedBox(height: 40.h),

                  PasswordInputField(
                    controller: _passwordController,
                    hintText: "New Password",
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                  SizedBox(height: 16.h),

                  PasswordInputField(
                    controller: _confirmPasswordController,
                    hintText: "Confirm Password",
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

                  SizedBox(height: 40.h),

                  AuthButton(
                    text: "RESET PASSWORD",
                    onPressed: _handleReset,
                    isLoading: ref.watch(authProvider).isLoading,
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
