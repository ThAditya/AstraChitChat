import 'dart:async';
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
import '../widgets/otp_input_field.dart';
import '../providers/auth_provider.dart';
import '../../../../core/router/app_router.dart';

class ResetPasswordOtpScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordOtpScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordOtpScreen> createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends ConsumerState<ResetPasswordOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _timerSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _otpController.text;
    if (code.length != 6) {
      _showSnackBar("Please enter the 6-digit code");
      return;
    }

    try {
      final resetToken = await ref.read(authProvider.notifier).verifyResetCode(widget.email, code);
      if (mounted) {
        context.push(
          AppRouter.newPassword,
          extra: {'resetToken': resetToken},
        );
      }
    } catch (e) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        _showSnackBar(error);
      }
    }
  }

  Future<void> _handleResend() async {
    try {
      await ref.read(authProvider.notifier).forgotPassword(widget.email);
      _startTimer();
      _showSnackBar("Reset code resent!", isError: false);
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

                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryNeon.withOpacity(0.1),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Iconsax.password_check_copy,
                            size: 60.sp,
                            color: AppColors.primaryNeon,
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                        SizedBox(height: 32.h),

                        Text(
                          "Enter Reset Code",
                          style: GoogleFonts.orbitron(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms),

                        SizedBox(height: 12.h),

                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: "We have sent a 6-digit code to\n"),
                              TextSpan(
                                text: widget.email,
                                style: TextStyle(
                                  color: AppColors.primaryNeon,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),

                  SizedBox(height: 50.h),

                  Center(
                    child: OtpInputField(
                      controller: _otpController,
                      onCompleted: (pin) => _handleVerify(),
                    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                  ),

                  SizedBox(height: 40.h),

                  Center(
                    child: Column(
                      children: [
                        Text(
                          _canResend ? "Didn't receive code?" : "Resend code in 00:${_timerSeconds.toString().padLeft(2, '0')}",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                        if (_canResend)
                          TextButton(
                            onPressed: _handleResend,
                            child: Text(
                              "RESEND CODE",
                              style: GoogleFonts.orbitron(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNeon,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  SizedBox(height: 40.h),

                  AuthButton(
                    text: "VERIFY CODE",
                    onPressed: _handleVerify,
                    isLoading: ref.watch(authProvider).isLoading,
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
