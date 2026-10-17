// DEVELOPMENT ONLY. Deleted in Stage F11.
import '../models/slot.dart';
import '../services/slot_service.dart';

class MockSlotService implements SlotService {
  static final _now = DateTime.now();

  final List<Slot> _slots = [
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

  int _nextId = 34;

  @override
  Future<Slot> create({
    required DateTime startTime, required DateTime endTime,
    required String mode, required String locationOrLink,
  }) async {
    await _delay();
    if (endTime.isBefore(startTime)) throw Exception('End time must be after start time.');
    if (locationOrLink.trim().isEmpty) throw Exception('Location or meeting link is required.');
    final slot = Slot(
      id: _nextId++,
      startTime: startTime, endTime: endTime,
      mode: SlotMode.fromString(mode),
      locationOrLink: locationOrLink.trim(),
      booked: false, requestCount: 0,
    );
    _slots.add(slot);
    return slot;
  }

  @override
  Future<List<Slot>> mine() async {
    await _delay();
    return List.from(_slots);
  }

  @override
  Future<void> delete(int id) async {
    await _delay();
    final slot = _slots.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Slot not found.'),
    );
    if (slot.booked) throw Exception('Cannot delete a booked slot.');
    _slots.removeWhere((s) => s.id == id);
  }

  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 450));
}
