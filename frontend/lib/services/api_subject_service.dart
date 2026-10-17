import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/subject.dart';
import 'subject_service.dart';

class ApiSubjectService implements SubjectService {
  final Dio _dio = ApiClient.dio;

  // 4. GET /subjects
  @override
  Future<List<Subject>> list() async {
    final res = await _dio.get('/subjects');
    return (res.data as List<dynamic>)
        .map((e) => Subject.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 21. POST /subjects
  @override
  Future<Subject> create(String name) async {
    final res = await _dio.post('/subjects', data: {'name': name.trim()});
    return Subject.fromJson(res.data as Map<String, dynamic>);
  }
}
