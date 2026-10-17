import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

// Dio singleton with JWT interceptor per Architecture.md Section 7.3.
// On 401: clears the stored token. AuthProvider listens via ChangeNotifier
// and go_router redirect will send the user to /login.
class ApiClient {
  ApiClient._();

  static final Dio dio = _build();

  static Dio _build() {
    final d = Dio(BaseOptions(
      baseUrl:        kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers:        {'Content-Type': 'application/json'},
    ));

    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(kTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(kTokenKey);
          // AuthProvider.restoreSession() will be triggered
          // by the next router refresh cycle.
        }
        return handler.next(e);
      },
    ));

    return d;
  }

  // Convert a DioException into a human-readable message using the
  // contract's error JSON {"message": "..."} with a network fallback.
  static String errorMessage(Object error) {
    if (error is DioException) {
      // Server returned a JSON error body
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] is String) {
        return data['message'] as String;
      }
      // Network / connection error
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Cannot reach the server. Check your connection.';
      }
      return error.message ?? 'An unexpected error occurred.';
    }
    return error.toString();
  }
}
