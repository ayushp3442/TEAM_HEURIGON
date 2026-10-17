// Architecture.md Section 6.5 — Slots (endpoints 7, 10, 11, 12)

enum SlotMode {
  online,
  onCampus;

  static SlotMode fromString(String s) =>
      s.toUpperCase() == 'ON_CAMPUS' ? SlotMode.onCampus : SlotMode.online;

  String toApiString() => this == SlotMode.onCampus ? 'ON_CAMPUS' : 'ONLINE';

  String get label => this == SlotMode.onCampus ? 'On Campus' : 'Online';
}

class Slot {
  final int       id;
  final DateTime  startTime;
  final DateTime  endTime;
  final SlotMode  mode;
  final String    locationOrLink;
  final bool      booked;
  final int?      requestCount; // only in endpoint 11 (GET /slots/mine)

  const Slot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.mode,
    required this.locationOrLink,
    required this.booked,
    this.requestCount,
  });

  factory Slot.fromJson(Map<String, dynamic> j) => Slot(
        id:             j['id'] as int,
        startTime:      DateTime.parse(j['startTime'] as String),
        endTime:        DateTime.parse(j['endTime'] as String),
        mode:           SlotMode.fromString(j['mode'] as String),
        locationOrLink: j['locationOrLink'] as String? ?? '',
        booked:         j['booked'] as bool? ?? false,
        requestCount:   j['requestCount'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'startTime':      startTime.toIso8601String().substring(0, 19),
        'endTime':        endTime.toIso8601String().substring(0, 19),
        'mode':           mode.toApiString(),
        'locationOrLink': locationOrLink,
        'booked':         booked,
        if (requestCount != null) 'requestCount': requestCount,
      };
}

// Minimal slot embedded in session request objects
class SlotRef {
  final int      id;
  final DateTime startTime;
  final DateTime endTime;
  final String   mode;
  final String   locationOrLink;

  const SlotRef({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.mode,
    required this.locationOrLink,
  });

  factory SlotRef.fromJson(Map<String, dynamic> j) => SlotRef(
        id:             j['id'] as int,
        startTime:      DateTime.parse(j['startTime'] as String),
        endTime:        DateTime.parse(j['endTime'] as String),
        mode:           j['mode'] as String? ?? 'ONLINE',
        locationOrLink: j['locationOrLink'] as String? ?? '',
      );
}
