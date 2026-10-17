import 'package:intl/intl.dart';

// Date/time formatting helpers used across all screens.
// Format: "Tue 20 Oct, 3:00 PM" and remaining-time "18h 32m left".

class AppFormatters {
  AppFormatters._();

  static final _dateTime = DateFormat("EEE d MMM, h:mm a");
  static final _dateOnly = DateFormat("EEE d MMM");
  static final _timeOnly = DateFormat("h:mm a");
  static final _apiDate  = DateFormat("yyyy-MM-dd");

  /// "Tue 20 Oct, 3:00 PM"
  static String dateTime(DateTime dt) => _dateTime.format(dt);

  /// "Tue 20 Oct"
  static String date(DateTime dt) => _dateOnly.format(dt);

  /// "3:00 PM"
  static String time(DateTime dt) => _timeOnly.format(dt);

  /// "2026-10-20" — for API query params
  static String apiDate(DateTime dt) => _apiDate.format(dt);

  /// Remaining time from now until [deadline]: "18h 32m left" or "Closed"
  static String remaining(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return 'Closed';
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m left';
    if (m > 0) return '${m}m left';
    return 'Less than a minute left';
  }

  /// Duration between two DateTimes: "1h 30m"
  static String duration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}
