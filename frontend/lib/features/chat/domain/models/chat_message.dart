import 'chat_model.dart';

enum MessageType { text, image, voice, file, call }

class ChatMessage {
  final String id;
  final String senderId;
  final String? text;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final String? mediaUrl;
  final String? fileName;
  final String? fileSize;
  final String? duration;
  final ChatMessage? replyTo;
  final bool isForwarded;

  ChatMessage({
    required this.id,
    required this.senderId,
    this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.duration,
    this.replyTo,
    this.isForwarded = false,
  });

  bool get isMe => senderId == 'me';
}

final List<ChatMessage> mockMessages = [
  ChatMessage(
    id: '1',
    senderId: 'other',
    text: 'Hey! Have you seen the new design concepts for the app?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    status: MessageStatus.read,
  ),
  ChatMessage(
    id: '2',
    senderId: 'me',
    text: 'Not yet, send them over!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
    status: MessageStatus.read,
  ),
  ChatMessage(
    id: '3',
    senderId: 'other',
    type: MessageType.image,
    mediaUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&auto=format&fit=crop&q=60',
    timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    status: MessageStatus.read,
  ),
  ChatMessage(
    id: '4',
    senderId: 'other',
    text: 'Check this out, I think the neon glow effect really pops.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    status: MessageStatus.read,
  ),
  ChatMessage(
    id: '5',
    senderId: 'me',
    text: 'Wow, this looks incredible! 🚀',
    timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
    status: MessageStatus.read,
    replyTo: ChatMessage(
      id: '4',
      senderId: 'other',
      text: 'Check this out, I think the neon glow effect really pops.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ),
  ChatMessage(
    id: '6',
    senderId: 'other',
    type: MessageType.voice,
    duration: '0:24',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    status: MessageStatus.read,
  ),
  ChatMessage(
    id: '7',
    senderId: 'me',
    text: 'I agree. Let\'s finalize this by tomorrow.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    status: MessageStatus.delivered,
  ),
  ChatMessage(
    id: '8',
    senderId: 'other',
    type: MessageType.file,
    fileName: 'Project_Specs.pdf',
    fileSize: '2.4 MB',
    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    status: MessageStatus.sent,
  ),
  ChatMessage(
    id: '9',
    senderId: 'me',
    type: MessageType.call,
    text: 'Video Call',
    duration: '12:05',
    timestamp: DateTime.now().subtract(const Duration(seconds: 45)),
  ),
  ChatMessage(
    id: '10',
    senderId: 'other',
    type: MessageType.call,
    text: 'Missed Voice Call',
    timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
  ),
];
