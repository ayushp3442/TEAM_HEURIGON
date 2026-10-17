// Architecture.md Section 6.3
// { "id": 1, "name": "Mathematics" }
class Subject {
  final int    id;
  final String name;

  const Subject({required this.id, required this.name});

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
        id:   j['id'] as int,
        name: j['name'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) => other is Subject && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
