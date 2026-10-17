// DEVELOPMENT ONLY. Deleted in Stage F11.
import '../models/tutor.dart';
import '../models/slot.dart';
import '../models/subject.dart';
import '../services/tutor_service.dart';

class MockTutorService implements TutorService {
  static final _now = DateTime.now();

  static final _subjects = [
    const Subject(id: 4, name: 'Data Structures'),
    const Subject(id: 5, name: 'DBMS'),
    const Subject(id: 2, name: 'Physics'),
    const Subject(id: 1, name: 'Mathematics'),
    const Subject(id: 10, name: 'Machine Learning'),
  ];

  static final List<TutorSummary> _tutors = [
    TutorSummary(
      id: 7, name: 'Priya Verma',
      bio: '3rd-year CSE student. Happy to help with DSA and DBMS.',
      department: 'Computer Science', yearOfStudy: 3,
      subjects: [_subjects[0], _subjects[1]],
      openSlotCount: 4,
      nextSlot: NextSlotInfo(
        startTime: _now.add(const Duration(hours: 2)), mode: 'ONLINE',
      ),
    ),
    TutorSummary(
      id: 8, name: 'Rajan Mehta',
      bio: 'Physics enthusiast. B.Sc 2nd year, love teaching mechanics and optics.',
      department: 'Physics', yearOfStudy: 2,
      subjects: [_subjects[2]],
      openSlotCount: 2,
      nextSlot: NextSlotInfo(
        startTime: _now.add(const Duration(days: 1)), mode: 'ON_CAMPUS',
      ),
    ),
    TutorSummary(
      id: 9, name: 'Sneha Iyer',
      bio: 'Final year Math student, tutoring calculus and linear algebra.',
      department: 'Mathematics', yearOfStudy: 4,
      subjects: [_subjects[3]],
      openSlotCount: 3,
      nextSlot: NextSlotInfo(
        startTime: _now.add(const Duration(hours: 5)), mode: 'ONLINE',
      ),
    ),
    TutorSummary(
      id: 10, name: 'Karan Patel',
      bio: 'ML enthusiast. Working on NLP projects. Happy to help with ML basics.',
      department: 'Computer Science', yearOfStudy: 3,
      subjects: [_subjects[4]],
      openSlotCount: 1,
      nextSlot: NextSlotInfo(
        startTime: _now.add(const Duration(days: 2)), mode: 'ONLINE',
      ),
    ),
  ];

  static final _profile = TutorProfile(
    id: 7, userId: 2, name: 'Priya Verma',
    bio: '3rd-year CSE student. Happy to help with DSA and DBMS.',
    department: 'Computer Science', yearOfStudy: 3,
    subjects: [_subjects[0], _subjects[1]],
  );

  static List<Slot> _slots(int tutorId) => [
    Slot(
      id: 31,
      startTime: _now.add(const Duration(hours: 2)),
      endTime:   _now.add(const Duration(hours: 3)),
      mode: SlotMode.online,
      locationOrLink: 'https://meet.google.com/abc-defg-hij',
      booked: false, requestCount: 2,
    ),
    Slot(
      id: 32,
      startTime: _now.add(const Duration(days: 1)),
      endTime:   _now.add(const Duration(days: 1, hours: 1)),
      mode: SlotMode.onCampus,
      locationOrLink: 'Library Room 204',
      booked: false, requestCount: 0,
    ),
    Slot(
      id: 33,
      startTime: _now.add(const Duration(days: 2)),
      endTime:   _now.add(const Duration(days: 2, hours: 2)),
      mode: SlotMode.online,
      locationOrLink: 'https://zoom.us/j/12345',
      booked: true, requestCount: 1,
    ),
  ];

  @override
  Future<List<TutorSummary>> search({
    int? subjectId, String? mode, String? date,
  }) async {
    await _delay();
    var result = List<TutorSummary>.from(_tutors);
    if (subjectId != null) {
      result = result
          .where((t) => t.subjects.any((s) => s.id == subjectId))
          .toList();
    }
    if (mode != null && mode.isNotEmpty) {
      result = result
          .where((t) => t.nextSlot?.mode == mode)
          .toList();
    }
    return result;
  }

  @override
  Future<TutorProfile> getById(int id) async {
    await _delay();
    if (id == 999) throw Exception('Tutor not found.');
    return _profile;
  }

  @override
  Future<List<Slot>> getSlotsForTutor(int tutorId) async {
    await _delay();
    return _slots(tutorId).where((s) => !s.booked).toList();
  }

  @override
  Future<TutorProfile?> me() async {
    await _delay();
    return _profile;
  }

  @override
  Future<TutorProfile> upsertMe({
    required String bio, required String department,
    required int yearOfStudy, required List<int> subjectIds,
  }) async {
    await _delay(ms: 700);
    return TutorProfile(
      id: 7, userId: 2, name: 'Priya Verma',
      bio: bio, department: department, yearOfStudy: yearOfStudy,
      subjects: _subjects
          .where((s) => subjectIds.contains(s.id))
          .toList(),
    );
  }

  static Future<void> _delay({int ms = 500}) =>
      Future.delayed(Duration(milliseconds: ms));
}
