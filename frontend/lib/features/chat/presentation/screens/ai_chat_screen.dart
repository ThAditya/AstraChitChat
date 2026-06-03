import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/particle_background.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [{'isMe': false, 'text': 'Hello! I am your Chit-Chat AI assistant. How can I help you today?', 'time': 'Just now'}];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() { _messages.add({'isMe': true, 'text': _controller.text, 'time': 'Just now'}); _controller.clear(); });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() { _messages.add({'isMe': false, 'text': _getAiResponse(_messages.last['text']), 'time': 'Just now'}); });
    });
  }

  String _getAiResponse(String query) {
    query = query.toLowerCase();
    if (query.contains('hello')) return 'Hi there! Ready to explore Chit-Chat?';
    if (query.contains('group')) return 'To create a group, click the + icon and select "Add Group".';
    return 'I am here to help you navigate Chit-Chat!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => context.pop()), title: Row(children: [Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.secondaryNeon, AppColors.primaryNeon])), child: Icon(Iconsax.magic_star_copy, size: 20.sp, color: Colors.white)), SizedBox(width: 12.w), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Chit-Chat AI', style: GoogleFonts.orbitron(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)), Text('Always active', style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.success))])])),
      body: Stack(children: [const ParticleBackground(), Column(children: [Expanded(child: ListView.builder(padding: EdgeInsets.all(20.r), itemCount: _messages.length, itemBuilder: (context, index) { final msg = _messages[index]; final isMe = msg['isMe']; return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: EdgeInsets.only(bottom: 16.h), padding: EdgeInsets.all(16.r), constraints: BoxConstraints(maxWidth: 0.75.sw), decoration: BoxDecoration(color: isMe ? AppColors.secondaryNeon.withOpacity(0.1) : AppColors.surface, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r), bottomLeft: Radius.circular(isMe ? 20.r : 4.r), bottomRight: Radius.circular(isMe ? 4.r : 20.r)), border: Border.all(color: isMe ? AppColors.secondaryNeon.withOpacity(0.3) : Colors.white.withOpacity(0.05))), child: Text(msg['text'], style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp))).animate().fadeIn().slideX(begin: isMe ? 0.2 : -0.2)); })), _buildInput()])]),
    );
  }

  Widget _buildInput() {
    return Container(padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.h), child: Row(children: [Expanded(child: Container(padding: EdgeInsets.symmetric(horizontal: 16.w), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(30.r), border: Border.all(color: Colors.white.withOpacity(0.1))), child: TextField(controller: _controller, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Ask me anything...', hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14.sp), border: InputBorder.none), onSubmitted: (_) => _sendMessage()))), SizedBox(width: 12.w), GestureDetector(onTap: _sendMessage, child: Container(padding: EdgeInsets.all(12.r), decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient), child: const Icon(Iconsax.send_1_copy, color: Colors.black)))]));
  }
}
