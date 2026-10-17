import '../models/chat.dart';

// Endpoints 18, 19, 20 (Architecture.md Section 6.8)
abstract class ChatService {
  // 18. GET /chats
  Future<List<ChatListItem>> list();

  // 19. GET /requests/{id}/messages?afterId=
  Future<MessageListResponse> messages(int requestId, {int afterId = 0});

  // 20. POST /requests/{id}/messages
  Future<ChatMessage> send(int requestId, String content);
}
