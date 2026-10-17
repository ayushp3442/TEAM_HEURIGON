import 'subject.dart';
import 'slot.dart';

// Architecture.md Section 6.6 and 6.8
// Endpoints 13, 14, 15, 16, 17 all return this shape.

// Enums matching Architecture.md Section 4.5
enum RequestStatus {
  pending,
  accepted,
  declined,
  cancelled;

  static RequestStatus fromString(String s) {
    switch (s.toUpperCase()) {
      case 'ACCEPTED':  return RequestStatus.accepted;
      case 'DECLINED':  return RequestStatus.declined;
      case 'CANCELLED': return RequestStatus.cancelled;
      default:          return RequestStatus.pending;
    }
  }

  String toApiString() => name.toUpperCase();

  String get label {
    switch (this) {
      case RequestStatus.pending:   return 'Pending';
      case RequestStatus.accepted:  return 'Accepted';
      case RequestStatus.declined:  return 'Declined';
      case RequestStatus.cancelled: return 'Cancelled';
    }
  }
}

enum ChatState {
  notStarted,
  open,
  closed;

  static ChatState fromString(String s) {
    switch (s.toUpperCase()) {
      case 'OPEN':        return ChatState.open;
      case 'CLOSED':      return ChatState.closed;
      default:            return ChatState.notStarted;
    }
  }
}

// Embedded "chat" object in request responses (Section 6.8)
class ChatInfo {
  final ChatState state;
  final DateTime  opensAt;
  final DateTime  closesAt;

  const ChatInfo({
    required this.state,
    required this.opensAt,
    required this.closesAt,
  });

  factory ChatInfo.fromJson(Map<String, dynamic> j) => ChatInfo(
        state:    ChatState.fromString(j['state'] as String),
        opensAt:  DateTime.parse(j['opensAt'] as String),
        closesAt: DateTime.parse(j['closesAt'] as String),
      );
}

// Mini user ref embedded in request objects
class UserRef {
  final int    id;
  final String name;

  const UserRef({required this.id, required this.name});

  factory UserRef.fromJson(Map<String, dynamic> j) => UserRef(
        id:   j['id'] as int,
        name: j['name'] as String,
      );
}

// Full session request object (endpoints 13-17)
class SessionRequest {
  final int           id;
  final RequestStatus status;
  final String        message;
  final DateTime      createdAt;
  final UserRef       student;
  final UserRef       tutor;    // name field = tutor's user name
  final Subject       subject;
  final SlotRef       slot;
  final ChatInfo?     chat;     // null unless status == ACCEPTED

  const SessionRequest({
    required this.id,
    required this.status,
    required this.message,
    required this.createdAt,
    required this.student,
    required this.tutor,
    required this.subject,
    required this.slot,
    this.chat,
  });

  factory SessionRequest.fromJson(Map<String, dynamic> j) => SessionRequest(
        id:        j['id'] as int,
        status:    RequestStatus.fromString(j['status'] as String),
        message:   j['message'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        student:   UserRef.fromJson(j['student'] as Map<String, dynamic>),
        tutor:     UserRef.fromJson(j['tutor'] as Map<String, dynamic>),
        subject:   Subject.fromJson(j['subject'] as Map<String, dynamic>),
        slot:      SlotRef.fromJson(j['slot'] as Map<String, dynamic>),
        chat:      j['chat'] == null
            ? null
            : ChatInfo.fromJson(j['chat'] as Map<String, dynamic>),
      );
}
