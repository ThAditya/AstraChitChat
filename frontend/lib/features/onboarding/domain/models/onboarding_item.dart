import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

final List<OnboardingItem> onboardingData = [
  OnboardingItem(
    title: "Secure Messaging",
    description: "Military-grade end-to-end encryption for every message, file, and voice note.",
    icon: Icons.shield_rounded,
    gradient: [const Color(0xFF00D1FF), const Color(0xFF0055FF)],
  ),
  OnboardingItem(
    title: "Private Video Calls",
    description: "Crystal clear HD voice and video calls with advanced privacy protocols.",
    icon: Icons.video_camera_back_rounded,
    gradient: [const Color(0xFF9D00FF), const Color(0xFF6E00FF)],
  ),
  OnboardingItem(
    title: "Reels & Community",
    description: "Explore trending short-form videos and connect with creators worldwide.",
    icon: Icons.auto_awesome_motion_rounded,
    gradient: [const Color(0xFFFF00D6), const Color(0xFFFF0055)],
  ),
  OnboardingItem(
    title: "Screenshot Alerts",
    description: "Stay in control with instant alerts when someone takes a screenshot of your chat.",
    icon: Icons.screenshot_rounded,
    gradient: [const Color(0xFF00FFA3), const Color(0xFF00AA6B)],
  ),
];
