import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum Role { student, tutor }

// ---------------------------------------------------------------------------
// AuthProvider — global auth state
// Injected with AuthService so screens call login/register/logout here.
// ChangeNotifier drives go_router's refreshListenable redirect.
// ---------------------------------------------------------------------------
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  String?  _token;
  AppUser? _user;
  bool     _isLoading = false;
  String?  _sessionError;

  // Getters
  bool     get isLoggedIn      => _token != null;
  bool     get isTutor         => _user?.isTutor ?? false;
  bool     get hasTutorProfile => _user?.hasTutorProfile ?? false;
  bool     get isLoading       => _isLoading;
  AppUser? get user            => _user;
  String   get displayName     => _user?.name ?? '';
  String   get email           => _user?.email ?? '';
  String?  get sessionError    => _sessionError;

  String get initials {
    final name = _user?.name ?? '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  // ---------------------------------------------------------------------------
  // Session restore — called in main.dart on startup.
  // Reads stored token, then calls GET /auth/me to re-populate user fields.
  // ---------------------------------------------------------------------------
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kTokenKey);
    if (token == null) return;

    _token = token;
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.me();
      _user = user;
      _sessionError = null;
    } catch (_) {
      // Token invalid or network error — clear the session
      await _clearStorage();
      _token = null;
      _user  = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Login — POST /auth/login
  // Throws a readable String on failure (caught in LoginScreen).
  // ---------------------------------------------------------------------------
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await _authService.login(email: email, password: password);
      await _saveSession(resp);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Register — POST /auth/register
  // ---------------------------------------------------------------------------
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role, // "STUDENT" | "TUTOR"
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await _authService.register(
        name: name, email: email, password: password, role: role,
      );
      await _saveSession(resp);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    await _clearStorage();
    _token = null;
    _user  = null;
    notifyListeners();
  }

  // Called by the API client's 401 interceptor
  Future<void> onUnauthorized() async {
    await _clearStorage();
    _token = null;
    _user  = null;
    notifyListeners();
  }

  // Mark that the tutor has created a profile (after PUT /tutors/me)
  void setHasTutorProfile(bool value) {
    if (_user == null) return;
    _user = AppUser(
      id: _user!.id,
      name: _user!.name,
      email: _user!.email,
      role: _user!.role,
      hasTutorProfile: value,
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------
  Future<void> _saveSession(AuthResponse resp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kTokenKey, resp.token);
    _token = resp.token;
    _user  = resp.user;
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTokenKey);
  }
}
