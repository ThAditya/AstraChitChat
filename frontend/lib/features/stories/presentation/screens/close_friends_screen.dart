import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';

class CloseFriendsScreen extends StatefulWidget {
  const CloseFriendsScreen({super.key});

  @override
  State<CloseFriendsScreen> createState() => _CloseFriendsScreenState();
}

class _CloseFriendsScreenState extends State<CloseFriendsScreen> {
  final List<Map<String, String>> friends = [
    {'name': 'Alex Rivers', 'avatar': 'https://i.pravatar.cc/150?u=alex', 'isSelected': 'true'},
    {'name': 'Elena Grace', 'avatar': 'https://i.pravatar.cc/150?u=elena', 'isSelected': 'true'},
    {'name': 'Jordan Sky', 'avatar': 'https://i.pravatar.cc/150?u=jordan', 'isSelected': 'false'},
    {'name': 'Tech Pulse', 'avatar': 'https://i.pravatar.cc/150?u=tech', 'isSelected': 'false'},
    {'name': 'Sara Moon', 'avatar': 'https://i.pravatar.cc/150?u=sara', 'isSelected': 'false'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          'Close Friends',
          style: GoogleFonts.orbitron(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Done",
              style: GoogleFonts.inter(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          const ParticleBackground(),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.green),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "Close friends see stories with a green ring. We don't notify people when you add or remove them.",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final isSelected = friend['isSelected'] == 'true';
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                      leading: CircleAvatar(
                        radius: 24.r,
                        backgroundImage: NetworkImage(friend['avatar']!),
                      ),
                      title: Text(
                        friend['name']!,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                        onChanged: (value) {
                          setState(() {
                            friends[index]['isSelected'] = value.toString();
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
