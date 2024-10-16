class ActivityArea {
  final String id;

  final String nameFr;

  final String nameEn;

  final DateTime createdAt;

  final DateTime updatedAt;

  ActivityArea(
      {required this.id,
      required this.nameFr,
      required this.nameEn,
      required this.createdAt,
      required this.updatedAt});

  /// Used to create [ActivityArea] instance from a JSON file
  factory ActivityArea.fromJson(Map<String, dynamic> map) => ActivityArea(
      id: map['id'] as String,
      nameFr: map['nameFr'] as String,
      nameEn: map['nameEn'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String));

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameFr': nameFr,
        'nameEn': nameEn,
        'createdAt': createdAt.toString(),
        'updatedAt': updatedAt.toString(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityArea &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nameEn == other.nameEn &&
          nameFr == other.nameFr &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      nameFr.hashCode ^
      nameEn.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
