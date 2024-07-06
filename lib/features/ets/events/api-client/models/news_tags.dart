class NewsTags {
  final String id;

  final String name;

  final DateTime createdAt;

  final DateTime updatedAt;

  NewsTags(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt});

  /// Used to create [NewsTags] instance from a JSON file
  factory NewsTags.fromJson(Map<String, dynamic> map) => NewsTags(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String));

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toString(),
        'updatedAt': updatedAt.toString(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsTags &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
}
