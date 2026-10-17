import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/session_request.dart';
import 'request_service.dart';

class ApiRequestService implements RequestService {
  final Dio _dio = ApiClient.dio;

  // 13. POST /requests
  @override
  Future<SessionRequest> create({
    required int slotId, required int subjectId, required String message,
  }) async {
    final res = await _dio.post('/requests', data: {
      'slotId':    slotId,
      'subjectId': subjectId,
      'message':   message,
    });
    return SessionRequest.fromJson(res.data as Map<String, dynamic>);
  }

  // 14. GET /requests/outgoing
  @override
  Future<List<SessionRequest>> outgoing({String? status}) async {
    final res = await _dio.get('/requests/outgoing', queryParameters: {
      if (status != null) 'status': status,
    });
    return (res.data as List<dynamic>)
        .map((e) => SessionRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 15. PATCH /requests/{id}/cancel
  @override
  Future<SessionRequest> cancel(int id) async {
    final res = await _dio.patch('/requests/$id/cancel');
    return SessionRequest.fromJson(res.data as Map<String, dynamic>);
  }

  // 16. GET /requests/incoming
  @override
  Future<List<SessionRequest>> incoming({String? status}) async {
    try {
      final res = await _dio.get('/requests/incoming', queryParameters: {
        if (status != null) 'status': status,
      });
      return (res.data as List<dynamic>)
          .map((e) => SessionRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  // 17. PATCH /requests/{id}/status
  @override
  Future<SessionRequest> updateStatus(int id, String status) async {
    final res = await _dio.patch('/requests/$id/status', data: {'status': status});
    return SessionRequest.fromJson(res.data as Map<String, dynamic>);
  }
}
