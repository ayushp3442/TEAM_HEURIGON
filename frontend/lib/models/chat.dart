import 'session_request.dart';
import 'subject.dart';

// Architecture.md Section 6.8
// Endpoints 18, 19, 20 — chat-related models

// GET /chats item (endpoint 18)
class ChatListItem {
  final int       requestId;
  final UserRef   otherUser;
  final Subject   subject;
  final SlotRange slot;
  final ChatInfo  chat;
  final LastMessage? lastMessage;

  const ChatListItem({
    required this.requestId,
    required this.otherUser,
    required this.subject,
    required this.slot,
    required this.chat,
    this.lastMessage,
  });

  factory ChatListItem.fromJson(Map<String, dynamic> j) => ChatListItem(
        requestId: j['requestId'] as int,
        otherUser: UserRef.fromJson(j['otherUser'] as Map<String, dynamic>),
        subject:   Subject.fromJson(j['subject'] as Map<String, dynamic>),
        slot:      SlotRange.fromJson(j['slot'] as Map<String, dynamic>),
        chat:      ChatInfo.fromJson(j['chat'] as Map<String, dynamic>),
        lastMessage: j['lastMessage'] == null
            ? null
            : LastMessage.fromJson(j['lastMessage'] as Map<String, dynamic>),
      );
}

// Minimal slot range in chat list (no id, no mode in Section 6.8 example)
class SlotRange {
  final DateTime startTime;
  final DateTime endTime;

  const SlotRange({required this.startTime, required this.endTime});

  factory SlotRange.fromJson(Map<String, dynamic> j) => SlotRange(
        startTime: DateTime.parse(j['startTime'] as String),
        endTime:   DateTime.parse(j['endTime'] as String),
      );
}

// lastMessage in chat list
class LastMessage {
  final String   content;
  final DateTime sentAt;
  final int      senderId;

  const LastMessage({
    required this.content,
    required this.sentAt,
    required this.senderId,
  });

  factory LastMessage.fromJson(Map<String, dynamic> j) => LastMessage(
        content:  j['content'] as String,
        sentAt:   DateTime.parse(j['sentAt'] as String),
        senderId: j['senderId'] as int,
      );
}

// GET /requests/{id}/messages response (endpoint 19)
class MessageListResponse {
  final ChatInfo         chat;
  final List<ChatMessage> messages;

  const MessageListResponse({required this.chat, required this.messages});

  factory MessageListResponse.fromJson(Map<String, dynamic> j) =>
      MessageListResponse(
        chat:     ChatInfo.fromJson(j['chat'] as Map<String, dynamic>),
        messages: (j['messages'] as List<dynamic>)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// Single message (item in endpoint 19, full response of endpoint 20)
class ChatMessage {
  final int      id;
  final int      senderId;
  final String   senderName;
  final String   content;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id:         j['id'] as int,
        senderId:   j['senderId'] as int,
        senderName: j['senderName'] as String,
        content:    j['content'] as String,
        sentAt:     DateTime.parse(j['sentAt'] as String),
      );
}
