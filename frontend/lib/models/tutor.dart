import 'subject.dart';

// Architecture.md Section 6.4
// Endpoint 5 (GET /tutors) — search result card
// Endpoint 6/8 (GET /tutors/{id}, GET /tutors/me) — full profile

// Minimal slot info nested inside TutorSummary.nextSlot
class NextSlotInfo {
  final DateTime startTime;
  final String   mode; // "ONLINE" | "ON_CAMPUS"

  const NextSlotInfo({required this.startTime, required this.mode});

  factory NextSlotInfo.fromJson(Map<String, dynamic> j) => NextSlotInfo(
        startTime: DateTime.parse(j['startTime'] as String),
        mode:      j['mode'] as String,
      );
}

// Endpoint 5 — search result
class TutorSummary {
  final int           id;
  final String        name;
  final String        bio;
  final String        department;
  final int           yearOfStudy;
  final List<Subject> subjects;
  final int           openSlotCount;
  final NextSlotInfo? nextSlot;

  const TutorSummary({
    required this.id,
    required this.name,
    required this.bio,
    required this.department,
    required this.yearOfStudy,
    required this.subjects,
    required this.openSlotCount,
    this.nextSlot,
  });

  factory TutorSummary.fromJson(Map<String, dynamic> j) => TutorSummary(
        id:           j['id'] as int,
        name:         j['name'] as String,
        bio:          j['bio'] as String? ?? '',
        department:   j['department'] as String? ?? '',
        yearOfStudy:  j['yearOfStudy'] as int? ?? 0,
        subjects:     (j['subjects'] as List<dynamic>? ?? [])
            .map((e) => Subject.fromJson(e as Map<String, dynamic>))
            .toList(),
        openSlotCount: j['openSlotCount'] as int? ?? 0,
        nextSlot:     j['nextSlot'] == null
            ? null
            : NextSlotInfo.fromJson(j['nextSlot'] as Map<String, dynamic>),
      );
}

// Endpoints 6, 8 — full tutor profile
class TutorProfile {
  final int           id;       // tutor profile id
  final int           userId;
  final String        name;
  final String        bio;
  final String        department;
  final int           yearOfStudy;
  final List<Subject> subjects;

  const TutorProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.bio,
    required this.department,
    required this.yearOfStudy,
    required this.subjects,
  });

  factory TutorProfile.fromJson(Map<String, dynamic> j) => TutorProfile(
        id:          j['id'] as int,
        userId:      j['userId'] as int,
        name:        j['name'] as String,
        bio:         j['bio'] as String? ?? '',
        department:  j['department'] as String? ?? '',
        yearOfStudy: j['yearOfStudy'] as int? ?? 0,
        subjects:    (j['subjects'] as List<dynamic>? ?? [])
            .map((e) => Subject.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id':          id,
        'userId':      userId,
        'name':        name,
        'bio':         bio,
        'department':  department,
        'yearOfStudy': yearOfStudy,
        'subjects':    subjects.map((s) => s.toJson()).toList(),
      };
}
