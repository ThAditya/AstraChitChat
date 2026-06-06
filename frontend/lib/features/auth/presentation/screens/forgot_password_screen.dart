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
import '../widgets/email_input_field.dart';
import '../providers/auth_provider.dart';
import '../../../../core/router/app_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      _showSnackBar("Please enter a valid email address");
      return;
    }

    try {
      await ref.read(authProvider.notifier).forgotPassword(email);

      setState(() {
        _isSubmitted = true;
      });

      _showSnackBar("Reset code sent to your email!", isError: false);

      if (mounted) {
        context.push(AppRouter.resetPasswordOtp, extra: email);
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
                    'Forgot Password?',
                    style: GoogleFonts.orbitron(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  SizedBox(height: 12.h),

                  Text(
                    'Don\'t worry! It happens. Please enter the email address associated with your account.',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  SizedBox(height: 40.h),

                  EmailInputField(controller: _emailController)
                      .animate()
                      .fadeIn(delay: 600.ms)
                      .slideY(begin: 0.1),

                  SizedBox(height: 40.h),

                  AuthButton(
                    text: _isSubmitted ? "RESEND CODE" : "SEND RESET CODE",
                    onPressed: _handleSubmit,
                    isLoading: ref.watch(authProvider).isLoading,
                  ).animate().fadeIn(delay: 800.ms),

                  SizedBox(height: 24.h),

                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        "Remember Password? Login",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.primaryNeon,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
