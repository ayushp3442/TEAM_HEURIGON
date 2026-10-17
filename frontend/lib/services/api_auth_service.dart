import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/user.dart';
import 'auth_service.dart';

class ApiAuthService implements AuthService {
  final Dio _dio = ApiClient.dio;

  // 1. POST /auth/register
  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // 2. POST /auth/login
  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // 3. GET /auth/me
  @override
  Future<AppUser> me() async {
    final res = await _dio.get('/auth/me');
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }
}
