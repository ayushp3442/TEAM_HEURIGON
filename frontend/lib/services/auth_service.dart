import '../models/user.dart';

// Endpoints 1, 2, 3 (Architecture.md Section 6.2)
abstract class AuthService {
  // 1. POST /auth/register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String role, // "STUDENT" | "TUTOR"
  });

  // 2. POST /auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  // 3. GET /auth/me
  Future<AppUser> me();
}
