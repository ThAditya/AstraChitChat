enum CallType { voice, video }
enum CallStatus { incoming, outgoing, missed }

class CallLog {
  final String id;
  final String name;
  final String avatar;
  final DateTime timestamp;
  final CallType type;
  final CallStatus status;
  final String? duration;

  CallLog({
    required this.id,
    required this.name,
    required this.avatar,
    required this.timestamp,
    required this.type,
    required this.status,
    this.duration,
  });
}

final List<CallLog> mockCallLogs = [
  CallLog(
    id: '1',
    name: 'Alex Rivera',
    avatar: 'https://ui-avatars.com/api/?name=Alex+Rivera&background=00D1FF&color=fff',
    timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    type: CallType.video,
    status: CallStatus.outgoing,
    duration: '12:05',
  ),
  CallLog(
    id: '2',
    name: 'Sarah Chen',
    avatar: 'https://ui-avatars.com/api/?name=Sarah+Chen&background=9D00FF&color=fff',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    type: CallType.voice,
    status: CallStatus.missed,
  ),
  CallLog(
    id: '3',
    name: 'Marcus Wright',
    avatar: 'https://ui-avatars.com/api/?name=Marcus+Wright&background=00FFA3&color=fff',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    type: CallType.video,
    status: CallStatus.incoming,
    duration: '05:20',
  ),
  CallLog(
    id: '4',
    name: 'Jessica Lee',
    avatar: 'https://ui-avatars.com/api/?name=Jessica+Lee&background=FF00D6&color=fff',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    type: CallType.voice,
    status: CallStatus.outgoing,
    duration: '02:15',
  ),
];
