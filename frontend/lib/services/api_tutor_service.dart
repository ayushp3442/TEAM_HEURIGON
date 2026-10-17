import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/tutor.dart';
import '../models/slot.dart';
import 'tutor_service.dart';

class ApiTutorService implements TutorService {
  final Dio _dio = ApiClient.dio;

  // 5. GET /tutors
  @override
  Future<List<TutorSummary>> search({
    int? subjectId, String? mode, String? date,
  }) async {
    final res = await _dio.get('/tutors', queryParameters: {
      if (subjectId != null) 'subjectId': subjectId,
      if (mode != null)      'mode':      mode,
      if (date != null)      'date':      date,
    });
    return (res.data as List<dynamic>)
        .map((e) => TutorSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 6. GET /tutors/{id}
  @override
  Future<TutorProfile> getById(int id) async {
    final res = await _dio.get('/tutors/$id');
    return TutorProfile.fromJson(res.data as Map<String, dynamic>);
  }

  // 7. GET /tutors/{id}/slots
  @override
  Future<List<Slot>> getSlotsForTutor(int tutorId) async {
    final res = await _dio.get('/tutors/$tutorId/slots');
    return (res.data as List<dynamic>)
        .map((e) => Slot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 8. GET /tutors/me  — returns null on 404 (no profile yet)
  @override
  Future<TutorProfile?> me() async {
    try {
      final res = await _dio.get('/tutors/me');
      return TutorProfile.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  // 9. PUT /tutors/me
  @override
  Future<TutorProfile> upsertMe({
    required String bio,
    required String department,
    required int yearOfStudy,
    required List<int> subjectIds,
  }) async {
    final res = await _dio.put('/tutors/me', data: {
      'bio':         bio,
      'department':  department,
      'yearOfStudy': yearOfStudy,
      'subjectIds':  subjectIds,
    });
    return TutorProfile.fromJson(res.data as Map<String, dynamic>);
  }
}
