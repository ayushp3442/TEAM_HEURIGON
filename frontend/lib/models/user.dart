
// Architecture.md Section 6.2 — GET /auth/me response
// Also embedded in login/register response as "user" field.
class AppUser {
  final int    id;
  final String name;
  final String email;
  final String role; // "STUDENT" | "TUTOR"
  final bool   hasTutorProfile;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.hasTutorProfile = false,
  });

  bool get isTutor => role.toUpperCase() == 'TUTOR';

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id:              j['id'] as int,
        name:            j['name'] as String,
        email:           j['email'] as String,
        role:            j['role'] as String,
        hasTutorProfile: j['hasTutorProfile'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id':              id,
        'name':            name,
        'email':           email,
        'role':            role,
        'hasTutorProfile': hasTutorProfile,
      };
}

// Auth response wrapper (login + register)
class AuthResponse {
  final String  token;
  final AppUser user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
        token: j['token'] as String,
        user:  AppUser.fromJson(j['user'] as Map<String, dynamic>),
      );
}
