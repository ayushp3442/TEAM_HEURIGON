// DEVELOPMENT ONLY. Deleted in Stage F11.
import '../models/session_request.dart';
import '../models/subject.dart';
import '../models/slot.dart';
import '../services/request_service.dart';

class MockRequestService implements RequestService {
  static final _now = DateTime.now();

  // Mini refs for embedded objects
  static const _student   = UserRef(id: 1, name: 'Aarav Sharma');
  static const _tutor     = UserRef(id: 2, name: 'Priya Verma');
  static const _tutor2    = UserRef(id: 8, name: 'Rajan Mehta');
  static const _tutor3    = UserRef(id: 9, name: 'Sneha Iyer');
  static const _subjectDS = Subject(id: 4, name: 'Data Structures');
  static const _subjectPH = Subject(id: 2, name: 'Physics');
  static const _subjectMA = Subject(id: 1, name: 'Mathematics');

  static SlotRef _slot(int id, DateTime start, String mode, String loc) => SlotRef(
    id: id,
    startTime:      start,
    endTime:        start.add(const Duration(hours: 1)),
    mode:           mode,
    locationOrLink: loc,
  );

  // Chat states for all three possibilities
  static ChatInfo get _chatOpen => ChatInfo(
    state:    ChatState.open,
    opensAt:  _now.subtract(const Duration(hours: 1)),
    closesAt: _now.add(const Duration(hours: 23)),
  );

  static ChatInfo get _chatNotStarted => ChatInfo(
    state:    ChatState.notStarted,
    opensAt:  _now.add(const Duration(hours: 2)),
    closesAt: _now.add(const Duration(hours: 26)),
  );

  static ChatInfo get _chatClosed => ChatInfo(
    state:    ChatState.closed,
    opensAt:  _now.subtract(const Duration(hours: 25)),
    closesAt: _now.subtract(const Duration(hours: 24)),
  );

  final List<SessionRequest> _outgoing = [
    // 1. PENDING — can cancel
    SessionRequest(
      id: 55, status: RequestStatus.pending,
      message: 'Need help with graphs and BFS traversal before my semester exam.',
      createdAt: _now.subtract(const Duration(hours: 1)),
      student: _student, tutor: _tutor, subject: _subjectDS,
      slot: _slot(31, _now.add(const Duration(hours: 3)), 'ONLINE',
          'https://meet.google.com/abc-defg-hij'),
    ),
    // 2. ACCEPTED + chat OPEN
    SessionRequest(
      id: 56, status: RequestStatus.accepted,
      message: 'Can we cover dynamic programming and memoisation?',
      createdAt: _now.subtract(const Duration(days: 1)),
      student: _student, tutor: _tutor, subject: _subjectDS,
      slot: _slot(32, _now.subtract(const Duration(hours: 1)), 'ONLINE',
          'https://meet.google.com/xyz-uvw-rst'),
      chat: _chatOpen,
    ),
    // 3. ACCEPTED + chat NOT_STARTED — session in future
    SessionRequest(
      id: 60, status: RequestStatus.accepted,
      message: 'Looking for help with optics and wave theory.',
      createdAt: _now.subtract(const Duration(days: 2)),
      student: _student, tutor: _tutor2, subject: _subjectPH,
      slot: _slot(33, _now.add(const Duration(hours: 2)), 'ON_CAMPUS',
          'Library Room 204'),
      chat: _chatNotStarted,
    ),
    // 4. ACCEPTED + chat CLOSED — session already ended
    SessionRequest(
      id: 61, status: RequestStatus.accepted,
      message: 'Revision on calculus and integration techniques.',
      createdAt: _now.subtract(const Duration(days: 5)),
      student: _student, tutor: _tutor3, subject: _subjectMA,
      slot: _slot(34, _now.subtract(const Duration(days: 1, hours: 2)), 'ONLINE',
          'https://zoom.us/j/12345678'),
      chat: _chatClosed,
    ),
    // 5. DECLINED
    SessionRequest(
      id: 57, status: RequestStatus.declined,
      message: 'Help with DBMS normalisation and ER diagrams.',
      createdAt: _now.subtract(const Duration(days: 3)),
      student: _student, tutor: _tutor, subject: const Subject(id: 5, name: 'DBMS'),
      slot: _slot(29, _now.subtract(const Duration(days: 3)), 'ON_CAMPUS',
          'Room 102'),
    ),
    // 6. CANCELLED by student
    SessionRequest(
      id: 58, status: RequestStatus.cancelled,
      message: 'ML basics — cancelled as schedule changed.',
      createdAt: _now.subtract(const Duration(days: 4)),
      student: _student, tutor: const UserRef(id: 10, name: 'Karan Patel'),
      subject: const Subject(id: 10, name: 'Machine Learning'),
      slot: _slot(28, _now.subtract(const Duration(days: 4)), 'ONLINE',
          'https://meet.google.com/cancel-xyz'),
    ),
  ];

  // Incoming (for tutor dashboard — still same mock data structure)
  final List<SessionRequest> _incoming = [
    SessionRequest(
      id: 55, status: RequestStatus.pending,
      message: 'Need help with graphs and BFS before my exam.',
      createdAt: _now.subtract(const Duration(hours: 1)),
      student: _student, tutor: _tutor, subject: _subjectDS,
      slot: _slot(31, _now.add(const Duration(hours: 3)), 'ONLINE',
          'https://meet.google.com/abc-defg-hij'),
    ),
    SessionRequest(
      id: 59, status: RequestStatus.pending,
      message: 'Binary trees and heap sort help please.',
      createdAt: _now.subtract(const Duration(minutes: 30)),
      student: const UserRef(id: 3, name: 'Rohan Das'),
      tutor: _tutor, subject: _subjectDS,
      slot: _slot(31, _now.add(const Duration(hours: 3)), 'ONLINE',
          'https://meet.google.com/abc-defg-hij'),
    ),
    SessionRequest(
      id: 62, status: RequestStatus.accepted,
      message: 'Revision before finals.',
      createdAt: _now.subtract(const Duration(days: 1)),
      student: const UserRef(id: 4, name: 'Ananya Singh'),
      tutor: _tutor, subject: _subjectDS,
      slot: _slot(33, _now.add(const Duration(hours: 2)), 'ONLINE',
          'https://meet.google.com/abc-defg-hij'),
      chat: _chatNotStarted,
    ),
  ];

  int _nextId = 63;

  @override
  Future<SessionRequest> create({
    required int slotId, required int subjectId, required String message,
  }) async {
    await _delay();
    // Simulate 409 if a request already exists for slotId 31
    if (slotId == 31 && _outgoing.any((r) =>
        r.status == RequestStatus.pending &&
        r.slot.id == slotId)) {
      throw Exception('You already have a pending request for this slot.');
    }
    final req = SessionRequest(
      id: _nextId++, status: RequestStatus.pending,
      message: message,
      createdAt: DateTime.now(),
      student: _student, tutor: _tutor,
      subject: Subject(id: subjectId, name: 'Data Structures'),
      slot: _slot(slotId, _now.add(const Duration(hours: 3)),
          'ONLINE', 'https://meet.google.com/abc-defg-hij'),
    );
    _outgoing.insert(0, req);
    return req;
  }

  @override
  Future<List<SessionRequest>> outgoing({String? status}) async {
    await _delay();
    if (status == null) return List.from(_outgoing);
    final s = RequestStatus.fromString(status);
    return _outgoing.where((r) => r.status == s).toList();
  }

  @override
  Future<SessionRequest> cancel(int id) async {
    await _delay(ms: 600);
    final idx = _outgoing.indexWhere((r) => r.id == id);
    if (idx == -1) throw Exception('Request not found.');
    if (_outgoing[idx].status != RequestStatus.pending) {
      throw Exception('Only pending requests can be cancelled.');
    }
    final old = _outgoing[idx];
    final updated = SessionRequest(
      id: old.id, status: RequestStatus.cancelled,
      message: old.message, createdAt: old.createdAt,
      student: old.student, tutor: old.tutor,
      subject: old.subject, slot: old.slot,
    );
    _outgoing[idx] = updated;
    return updated;
  }

  @override
  Future<List<SessionRequest>> incoming({String? status}) async {
    await _delay();
    if (status == null) return List.from(_incoming);
    final s = RequestStatus.fromString(status);
    return _incoming.where((r) => r.status == s).toList();
  }

  @override
  Future<SessionRequest> updateStatus(int id, String status) async {
    await _delay(ms: 700);
    final idx = _incoming.indexWhere((r) => r.id == id);
    if (idx == -1) throw Exception('Request not found.');
    final newStatus = RequestStatus.fromString(status);
    final old = _incoming[idx];
    final updated = SessionRequest(
      id: old.id, status: newStatus,
      message: old.message, createdAt: old.createdAt,
      student: old.student, tutor: old.tutor,
      subject: old.subject, slot: old.slot,
      chat: newStatus == RequestStatus.accepted ? _chatNotStarted : null,
    );
    _incoming[idx] = updated;
    return updated;
  }

  static Future<void> _delay({int ms = 500}) =>
      Future.delayed(Duration(milliseconds: ms));
}
