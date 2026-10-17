// DEVELOPMENT ONLY. Deleted in Stage F11.
import 'package:dio/dio.dart';
import '../models/chat.dart';
import '../models/session_request.dart';
import '../models/subject.dart';
import '../services/chat_service.dart';

class MockChatService implements ChatService {
  static final _now = DateTime.now();

  static final List<ChatListItem> _chatList = [
    // 1. OPEN (18 hours left)
    ChatListItem(
      requestId: 56,
      otherUser: const UserRef(id: 2, name: 'Priya Verma'),
      subject: const Subject(id: 4, name: 'Data Structures'),
      slot: SlotRange(
        startTime: _now.subtract(const Duration(hours: 6)),
        endTime:   _now.subtract(const Duration(hours: 5)),
      ),
      chat: ChatInfo(
        state:    ChatState.open,
        opensAt:  _now.subtract(const Duration(hours: 5)),
        closesAt: _now.add(const Duration(hours: 18, minutes: 20)),
      ),
      lastMessage: LastMessage(
        content:  'Thanks, that makes sense!',
        sentAt:   _now.subtract(const Duration(minutes: 30)),
        senderId: 1,
      ),
    ),

    // 2. OPEN (< 1 hour left — accent color warning test)
    ChatListItem(
      requestId: 57,
      otherUser: const UserRef(id: 3, name: 'Dev Patel'),
      subject: const Subject(id: 1, name: 'Operating Systems'),
      slot: SlotRange(
        startTime: _now.subtract(const Duration(hours: 24)),
        endTime:   _now.subtract(const Duration(hours: 23, minutes: 15)),
      ),
      chat: ChatInfo(
        state:    ChatState.open,
        opensAt:  _now.subtract(const Duration(hours: 23, minutes: 15)),
        closesAt: _now.add(const Duration(minutes: 42)),
      ),
      lastMessage: LastMessage(
        content:  'Remember to check the semaphore synchronization notes.',
        sentAt:   _now.subtract(const Duration(minutes: 15)),
        senderId: 3,
      ),
    ),

    // 3. CLOSED
    ChatListItem(
      requestId: 58,
      otherUser: const UserRef(id: 4, name: 'Ananya Rao'),
      subject: const Subject(id: 2, name: 'Computer Networks'),
      slot: SlotRange(
        startTime: _now.subtract(const Duration(hours: 30)),
        endTime:   _now.subtract(const Duration(hours: 29)),
      ),
      chat: ChatInfo(
        state:    ChatState.closed,
        opensAt:  _now.subtract(const Duration(hours: 29)),
        closesAt: _now.subtract(const Duration(hours: 5)),
      ),
      lastMessage: LastMessage(
        content:  'You are welcome! Best of luck with the midterm.',
        sentAt:   _now.subtract(const Duration(hours: 6)),
        senderId: 4,
      ),
    ),

    // 4. NOT_STARTED
    ChatListItem(
      requestId: 59,
      otherUser: const UserRef(id: 5, name: 'Rohan Mehta'),
      subject: const Subject(id: 3, name: 'Algorithms'),
      slot: SlotRange(
        startTime: _now.add(const Duration(hours: 3)),
        endTime:   _now.add(const Duration(hours: 4)),
      ),
      chat: ChatInfo(
        state:    ChatState.notStarted,
        opensAt:  _now.add(const Duration(hours: 4)),
        closesAt: _now.add(const Duration(hours: 28)),
      ),
    ),
  ];

  static final Map<int, List<ChatMessage>> _messagesStore = {
    56: [
      ChatMessage(
        id: 101,
        senderId: 1,
        senderName: 'Aarav Sharma',
        content: 'Hi Priya, thanks for the session on binary trees!',
        sentAt: _now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ChatMessage(
        id: 102,
        senderId: 2,
        senderName: 'Priya Verma',
        content: 'Glad it helped! Remember to review tree traversals and recursion bases.',
        sentAt: _now.subtract(const Duration(days: 1, hours: 1, minutes: 45)),
      ),
      ChatMessage(
        id: 103,
        senderId: 1,
        senderName: 'Aarav Sharma',
        content: 'Quick question: why does BFS use a queue while DFS uses recursion or a stack?',
        sentAt: _now.subtract(const Duration(minutes: 50)),
      ),
      ChatMessage(
        id: 104,
        senderId: 2,
        senderName: 'Priya Verma',
        content: 'BFS visits nodes level by level, so a FIFO queue ensures we explore nearest neighbors before moving deeper.',
        sentAt: _now.subtract(const Duration(minutes: 42)),
      ),
      ChatMessage(
        id: 105,
        senderId: 1,
        senderName: 'Aarav Sharma',
        content: 'Thanks, that makes sense!',
        sentAt: _now.subtract(const Duration(minutes: 30)),
      ),
    ],
    57: [
      ChatMessage(
        id: 201,
        senderId: 1,
        senderName: 'Aarav Sharma',
        content: 'Thanks for explaining producer-consumer locks today!',
        sentAt: _now.subtract(const Duration(hours: 1, minutes: 10)),
      ),
      ChatMessage(
        id: 202,
        senderId: 3,
        senderName: 'Dev Patel',
        content: 'Remember to check the semaphore synchronization notes.',
        sentAt: _now.subtract(const Duration(minutes: 15)),
      ),
    ],
    58: [
      ChatMessage(
        id: 301,
        senderId: 1,
        senderName: 'Aarav Sharma',
        content: 'Thank you for the networking explanation and subnetting practice!',
        sentAt: _now.subtract(const Duration(hours: 8)),
      ),
      ChatMessage(
        id: 302,
        senderId: 4,
        senderName: 'Ananya Rao',
        content: 'You are welcome! Best of luck with the midterm.',
        sentAt: _now.subtract(const Duration(hours: 6)),
      ),
    ],
    59: [],
  };

  static int _nextMsgId = 401;

  @override
  Future<List<ChatListItem>> list() async {
    await _delay();
    return List.from(_chatList);
  }

  @override
  Future<MessageListResponse> messages(int requestId, {int afterId = 0}) async {
    await _delay(ms: 200);

    // Find chat metadata or use fallback
    final item = _chatList.firstWhere(
      (c) => c.requestId == requestId,
      orElse: () => ChatListItem(
        requestId: requestId,
        otherUser: const UserRef(id: 99, name: 'Peer Tutor'),
        subject: const Subject(id: 1, name: 'General'),
        slot: SlotRange(startTime: _now, endTime: _now.add(const Duration(hours: 1))),
        chat: ChatInfo(
          state: ChatState.open,
          opensAt: _now.subtract(const Duration(hours: 1)),
          closesAt: _now.add(const Duration(hours: 23)),
        ),
      ),
    );

    final msgs = _messagesStore[requestId] ?? [];
    final filtered = msgs.where((m) => m.id > afterId).toList();

    return MessageListResponse(
      chat: item.chat,
      messages: filtered,
    );
  }

  @override
  Future<ChatMessage> send(int requestId, String content) async {
    await _delay(ms: 300);

    // Simulate 409 if closed or forced test
    final chatItem = _chatList.firstWhere(
      (c) => c.requestId == requestId,
      orElse: () => _chatList.first,
    );

    if (chatItem.chat.state == ChatState.closed || content.contains('simulate-409')) {
      throw DioException(
        requestOptions: RequestOptions(path: '/requests/$requestId/messages'),
        response: Response(
          requestOptions: RequestOptions(path: '/requests/$requestId/messages'),
          statusCode: 409,
          data: {'message': 'This chat has closed. New messages cannot be sent.'},
        ),
      );
    }

    if (content.trim().isEmpty) throw Exception('Message cannot be blank.');
    if (content.length > 1000) throw Exception('Message too long (max 1000 chars).');

    final msg = ChatMessage(
      id: _nextMsgId++,
      senderId: 1,
      senderName: 'Aarav Sharma',
      content: content.trim(),
      sentAt: DateTime.now(),
    );

    _messagesStore.putIfAbsent(requestId, () => []).add(msg);

    // Update lastMessage in chat list
    final idx = _chatList.indexWhere((c) => c.requestId == requestId);
    if (idx != -1) {
      final old = _chatList[idx];
      _chatList[idx] = ChatListItem(
        requestId: old.requestId,
        otherUser: old.otherUser,
        subject: old.subject,
        slot: old.slot,
        chat: old.chat,
        lastMessage: LastMessage(
          content: msg.content,
          sentAt: msg.sentAt,
          senderId: msg.senderId,
        ),
      );
    }

    // Simulate other person replying after 2.5 seconds so polling (every 3s) receives it!
    Future.delayed(const Duration(milliseconds: 2500), () {
      final other = chatItem.otherUser;
      final reply = ChatMessage(
        id: _nextMsgId++,
        senderId: other.id,
        senderName: other.name,
        content: _generateSimulatedReply(content),
        sentAt: DateTime.now(),
      );
      _messagesStore.putIfAbsent(requestId, () => []).add(reply);

      // update last message
      final i = _chatList.indexWhere((c) => c.requestId == requestId);
      if (i != -1) {
        final current = _chatList[i];
        _chatList[i] = ChatListItem(
          requestId: current.requestId,
          otherUser: current.otherUser,
          subject: current.subject,
          slot: current.slot,
          chat: current.chat,
          lastMessage: LastMessage(
            content: reply.content,
            sentAt: reply.sentAt,
            senderId: reply.senderId,
          ),
        );
      }
    });

    return msg;
  }

  String _generateSimulatedReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('thank') || lower.contains('thx')) {
      return 'You are most welcome! Let me know if anything else comes up.';
    }
    if (lower.contains('question') || lower.contains('?') || lower.contains('how') || lower.contains('why')) {
      return 'Good question! Keep practicing those concepts and check chapter 4 for reference.';
    }
    if (lower.contains('notes') || lower.contains('link') || lower.contains('file')) {
      return 'I have sent the supplementary notes link to your student email.';
    }
    return 'Got it! Thanks for following up on our session.';
  }

  static Future<void> _delay({int ms = 400}) =>
      Future.delayed(Duration(milliseconds: ms));
}
