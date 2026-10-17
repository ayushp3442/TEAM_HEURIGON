import '../models/session_request.dart';

// Endpoints 13, 14, 15, 16, 17 (Architecture.md Section 6.6)
abstract class RequestService {
  // 13. POST /requests  (student)
  Future<SessionRequest> create({
    required int    slotId,
    required int    subjectId,
    required String message,
  });

  // 14. GET /requests/outgoing?status=  (student)
  Future<List<SessionRequest>> outgoing({String? status});

  // 15. PATCH /requests/{id}/cancel  (student)
  Future<SessionRequest> cancel(int id);

  // 16. GET /requests/incoming?status=  (tutor)
  Future<List<SessionRequest>> incoming({String? status});

  // 17. PATCH /requests/{id}/status  (tutor: ACCEPTED | DECLINED)
  Future<SessionRequest> updateStatus(int id, String status);
}
