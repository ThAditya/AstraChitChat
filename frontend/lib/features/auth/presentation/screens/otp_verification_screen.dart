import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/otp_input_field.dart';

import '../../../../core/router/app_router.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _timerSeconds = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 30;
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
                  
                  // Back Button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2),

                  SizedBox(height: 40.h),

                  // Header Section
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
                            Iconsax.shield_security,
                            size: 60.sp,
                            color: AppColors.primaryNeon,
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                        
                        SizedBox(height: 32.h),
                        
                        Text(
                          "Verify Number",
                          style: GoogleFonts.orbitron(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
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
                              const TextSpan(text: "Enter the OTP sent to\n"),
                              TextSpan(
                                text: widget.phoneNumber,
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

                  SizedBox(height: 60.h),

                  // OTP Input Section
                  Center(
                    child: OtpInputField(
                      controller: _otpController,
                      onCompleted: (pin) {
                        // Handle completion
                      },
                    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                  ),

                  SizedBox(height: 40.h),

                  // Timer & Resend
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
                            onPressed: _startTimer,
                            child: Text(
                              "RESEND OTP",
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

                  // Verify Button
                  AuthButton(
                    text: "VERIFY",
                    onPressed: () {
                      context.go(AppRouter.home);
                    },
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                  
                  SizedBox(height: 30.h),
                  
                  // Security Note
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.lock_1, size: 14.sp, color: AppColors.textGrey),
                        SizedBox(width: 8.w),
                        Text(
                          "End-to-End Encrypted Verification",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
