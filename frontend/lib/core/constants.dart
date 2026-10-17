// lib/core/constants.dart
// Base URL from compile-time env var. Override at build time with:
//   flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.x.x:8080/api
const String kAppName = 'StudyCircle';
const String kAppTagline = 'Learn Together. Grow Together.';

const String kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/api',
);
const String kContactEmail = String.fromEnvironment('CONTACT_EMAIL');
const String kTokenKey = 'auth_token';

// Breakpoints and layout
class AppLayout {
  AppLayout._();
  static const double mobileBreakpoint  = 600.0;
  static const double desktopBreakpoint = 1000.0;
  static const double maxContentWidth   = 1100.0;

  // 4/8 px spacing grid
  static const double space4  = 4.0;
  static const double space8  = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double pagePadding = 16.0;

  // Visual constants
  static const double radius6 = 6.0;
  static const double borderWidth1 = 1.0;
}
