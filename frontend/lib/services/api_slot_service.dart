import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/slot.dart';
import 'slot_service.dart';

class ApiSlotService implements SlotService {
  final Dio _dio = ApiClient.dio;

  // 10. POST /slots
  @override
  Future<Slot> create({
    required DateTime startTime,
    required DateTime endTime,
    required String   mode,
    required String   locationOrLink,
  }) async {
    final res = await _dio.post('/slots', data: {
      'startTime':      startTime.toIso8601String().substring(0, 19),
      'endTime':        endTime.toIso8601String().substring(0, 19),
      'mode':           mode,
      'locationOrLink': locationOrLink,
    });
    return Slot.fromJson(res.data as Map<String, dynamic>);
  }

  // 11. GET /slots/mine
  @override
  Future<List<Slot>> mine() async {
    final res = await _dio.get('/slots/mine');
    return (res.data as List<dynamic>)
        .map((e) => Slot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 12. DELETE /slots/{id}
  @override
  Future<void> delete(int id) async {
    await _dio.delete('/slots/$id');
  }
}
