// DEVELOPMENT ONLY. Deleted in Stage F11.
import '../models/subject.dart';
import '../services/subject_service.dart';

class MockSubjectService implements SubjectService {
  final List<Subject> _subjects = [
    const Subject(id: 1,  name: 'Mathematics'),
    const Subject(id: 2,  name: 'Physics'),
    const Subject(id: 3,  name: 'Chemistry'),
    const Subject(id: 4,  name: 'Data Structures'),
    const Subject(id: 5,  name: 'DBMS'),
    const Subject(id: 6,  name: 'Operating Systems'),
    const Subject(id: 7,  name: 'Computer Networks'),
    const Subject(id: 8,  name: 'English'),
    const Subject(id: 9,  name: 'Economics'),
    const Subject(id: 10, name: 'Machine Learning'),
  ];

  @override
  Future<List<Subject>> list() async {
    await _delay();
    return List.from(_subjects);
  }

  @override
  Future<Subject> create(String name) async {
    await _delay();
    final trimmed = name.trim();
    final existing = _subjects.where(
      (s) => s.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (existing.isNotEmpty) return existing.first;
    final newSubject = Subject(id: _subjects.length + 1, name: trimmed);
    _subjects.add(newSubject);
    return newSubject;
  }

  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 400));
}
