import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/chat.dart';
import 'chat_service.dart';

class ApiChatService implements ChatService {
  final Dio _dio = ApiClient.dio;

  // 18. GET /chats
  @override
  Future<List<ChatListItem>> list() async {
    final res = await _dio.get('/chats');
    return (res.data as List<dynamic>)
        .map((e) => ChatListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 19. GET /requests/{id}/messages?afterId=
  @override
  Future<MessageListResponse> messages(int requestId, {int afterId = 0}) async {
    final res = await _dio.get(
      '/requests/$requestId/messages',
      queryParameters: {'afterId': afterId},
    );
    return MessageListResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // 20. POST /requests/{id}/messages
  @override
  Future<ChatMessage> send(int requestId, String content) async {
    final res = await _dio.post(
      '/requests/$requestId/messages',
      data: {'content': content},
    );
    return ChatMessage.fromJson(res.data as Map<String, dynamic>);
  }
}
