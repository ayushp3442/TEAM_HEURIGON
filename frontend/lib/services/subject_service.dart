import '../models/subject.dart';

// Endpoints 4, 21 (Architecture.md Section 6.3)
abstract class SubjectService {
  // 4. GET /subjects
  Future<List<Subject>> list();

  // 21. POST /subjects  (tutor only)
  Future<Subject> create(String name);
}
