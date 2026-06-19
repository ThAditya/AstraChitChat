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
import '../widgets/name_input_field.dart';
import '../widgets/email_input_field.dart';
import '../widgets/password_input_field.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool _isPasswordStrong(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[@$!%*?&^#]').hasMatch(password);
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || name.length < 2) {
      _showSnackBar("Please enter a valid name (min 2 characters)");
      return;
    }
    if (email.isEmpty || !_isValidEmail(email)) {
      _showSnackBar("Please enter a valid email address");
      return;
    }
    if (!_isPasswordStrong(password)) {
      _showSnackBar("Password must be at least 8 chars with Uppercase, Lowercase, Digit and Special char");
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    await ref.read(authProvider.notifier).register(
          name: name,
          email: email,
          password: password,
        );

    final authState = ref.read(authProvider);
    if (authState.error != null) {
      _showSnackBar(authState.error!);
    } else if (authState.user != null) {
      _showSnackBar("Registration successful!", isError: false);
      context.go(AppRouter.home);
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
                  SizedBox(height: 40.h),

                  // Top Section: Logo
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryNeon.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                          child: Icon(
                            Icons.person_add_rounded,
                            size: 40.sp,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),

                      SizedBox(height: 16.h),

                      Text(
                        'CREATE ACCOUNT',
                        style: GoogleFonts.orbitron(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // Input Area
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NameInputField(controller: _nameController)
                          .animate()
                          .fadeIn()
                          .slideY(begin: 0.1),
                      SizedBox(height: 16.h),
                      EmailInputField(controller: _emailController)
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideY(begin: 0.1),
                      SizedBox(height: 16.h),
                      PasswordInputField(
                        controller: _passwordController,
                        hintText: "Password",
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      SizedBox(height: 16.h),
                      PasswordInputField(
                        controller: _confirmPasswordController,
                        hintText: "Confirm Password",
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // Register Button
                  AuthButton(
                    text: "REGISTER",
                    onPressed: _handleRegister,
                    isLoading: ref.watch(authProvider).isLoading,
                  ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),

                  SizedBox(height: 24.h),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          "Login",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.primaryNeon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
