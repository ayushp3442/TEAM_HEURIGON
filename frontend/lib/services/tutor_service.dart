import '../models/tutor.dart';
import '../models/slot.dart';

// Endpoints 5, 6, 7, 8, 9 (Architecture.md Section 6.4)
abstract class TutorService {
  // 5. GET /tutors?subjectId=&mode=&date=
  Future<List<TutorSummary>> search({
    int?    subjectId,
    String? mode,   // "ONLINE" | "ON_CAMPUS" | null
    String? date,   // "YYYY-MM-DD" | null
  });

  // 6. GET /tutors/{id}
  Future<TutorProfile> getById(int id);

  // 7. GET /tutors/{id}/slots
  Future<List<Slot>> getSlotsForTutor(int tutorId);

  // 8. GET /tutors/me  (404 if no profile yet)
  Future<TutorProfile?> me();

  // 9. PUT /tutors/me
  Future<TutorProfile> upsertMe({
    required String   bio,
    required String   department,
    required int      yearOfStudy,
    required List<int> subjectIds,
  });
}
