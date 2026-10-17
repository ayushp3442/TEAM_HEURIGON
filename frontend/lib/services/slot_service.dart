import '../models/slot.dart';

// Endpoints 10, 11, 12 (Architecture.md Section 6.5)
abstract class SlotService {
  // 10. POST /slots
  Future<Slot> create({
    required DateTime startTime,
    required DateTime endTime,
    required String   mode,            // "ONLINE" | "ON_CAMPUS"
    required String   locationOrLink,
  });

  // 11. GET /slots/mine
  Future<List<Slot>> mine();

  // 12. DELETE /slots/{id}  returns void (204)
  Future<void> delete(int id);
}
