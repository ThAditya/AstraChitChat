import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/particle_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/email_input_field.dart';
import '../widgets/password_input_field.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailLogin = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  Future<void> _handleLogin() async {
    if (_isEmailLogin) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || !_isValidEmail(email)) {
        _showSnackBar("Please enter a valid email address");
        return;
      }
      if (password.isEmpty) {
        _showSnackBar("Please enter your password");
        return;
      }

      await ref.read(authProvider.notifier).login(
            email: email,
            password: password,
          );

      final authState = ref.read(authProvider);
      if (authState.error != null) {
        _showSnackBar(authState.error!);
      } else if (authState.user != null) {
        _showSnackBar("Login successful!", isError: false);
        context.go(AppRouter.home);
      }
    } else {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _showSnackBar("Please enter your phone number");
        return;
      }
      context.push(
        AppRouter.otp,
        extra: "+91 $phone",
      );
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60.h),
                  
                  // Top Section: Logo & App Name
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryNeon.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                          child: Icon(
                            Icons.chat_bubble_rounded,
                            size: 60.sp,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                      
                      SizedBox(height: 24.h),
                      
                      Text(
                        'CHIT CHAT',
                        style: GoogleFonts.orbitron(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      
                      SizedBox(height: 8.h),
                      
                      Text(
                        'Private • Secure • Connected',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          letterSpacing: 1.5,
                          color: AppColors.primaryNeon.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                  
                  SizedBox(height: 50.h),
                  
                  // Middle Section: Input Area
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back",
                        style: GoogleFonts.orbitron(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                      
                      SizedBox(height: 12.h),
                      
                      Text(
                        _isEmailLogin 
                          ? "Login with your credentials"
                          : "Enter your phone number to continue",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ).animate(key: ValueKey(_isEmailLogin)).fadeIn(delay: 100.ms),
                      
                      SizedBox(height: 32.h),
                      
                      if (_isEmailLogin) ...[
                        EmailInputField(controller: _emailController)
                            .animate()
                            .fadeIn()
                            .slideY(begin: 0.1),
                        SizedBox(height: 16.h),
                        PasswordInputField(controller: _passwordController)
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .slideY(begin: 0.1),
                      ] else
                        PhoneInputField(controller: _phoneController)
                            .animate()
                            .fadeIn()
                            .slideY(begin: 0.1),
                    ],
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  // Continue Button
                  AuthButton(
                    text: _isEmailLogin ? "LOGIN" : "CONTINUE",
                    onPressed: _handleLogin,
                    isLoading: ref.watch(authProvider).isLoading,
                  ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.9, 0.9)),
                  
                  SizedBox(height: 24.h),
                  
                  // Toggle Button: Continue with Email/Phone
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEmailLogin = !_isEmailLogin;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isEmailLogin ? Iconsax.mobile_copy : Iconsax.direct_right_copy,
                          size: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _isEmailLogin ? "Continue with Phone" : "Continue with Email",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1100.ms),

                  SizedBox(height: 24.h),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.register),
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.primaryNeon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1150.ms),

                  SizedBox(height: 40.h),
                  
                  // Bottom Section: Terms
                  Column(
                    children: [
                      Text(
                        "By continuing, you agree to our",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Terms of Service",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.primaryNeon,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "&",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: AppColors.textGrey,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Privacy Policy",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.primaryNeon,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 1200.ms),
                  
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


