// DEVELOPMENT ONLY. Deleted in Stage F11.
import 'dart:async';
import '../models/user.dart';
import '../services/auth_service.dart';

class MockAuthService implements AuthService {
  static const _studentUser = AppUser(
    id: 1, name: 'Aarav Sharma', email: 'aarav@campus.edu',
    role: 'STUDENT', hasTutorProfile: false,
  );
  static const _tutorUser = AppUser(
    id: 2, name: 'Priya Verma', email: 'priya@campus.edu',
    role: 'TUTOR', hasTutorProfile: true,
  );

  @override
  Future<AuthResponse> register({
    required String name, required String email,
    required String password, required String role,
  }) async {
    await _delay();
    if (email == 'taken@campus.edu') throw Exception('Email already registered.');
    final user = role.toUpperCase() == 'TUTOR' ? _tutorUser : _studentUser;
    return AuthResponse(token: 'mock-token-${role.toLowerCase()}', user: user);
  }

  @override
  Future<AuthResponse> login({
    required String email, required String password,
  }) async {
    await _delay();
    if (password == 'wrong') throw Exception('Invalid email or password.');
    final isTutor = email.contains('tutor') || email == 'priya@campus.edu';
    final user = isTutor ? _tutorUser : _studentUser;
    return AuthResponse(
      token: 'mock-token-${isTutor ? 'tutor' : 'student'}', user: user,
    );
  }

  @override
  Future<AppUser> me() async {
    await _delay(ms: 300);
    return _studentUser;
  }

  static Future<void> _delay({int ms = 500}) =>
      Future.delayed(Duration(milliseconds: ms));
}
