// Package imports:
import 'package:xml/xml.dart';

/// Data-class that represents a replaced day.
class ReplacedDay {
  /// Original date being replaced (ex: holiday date).
  final DateTime originalDate;

  /// New date when classes will be held instead.
  final DateTime replacementDate;

  /// Reason for the replacement (ex: "Action de grâces").
  final String description;

  ReplacedDay({required this.originalDate, required this.replacementDate, required this.description});

  /// Used to create a new [ReplacedDay] instance from a [XMLElement].
  factory ReplacedDay.fromXmlNode(XmlElement node) => ReplacedDay(
    originalDate: DateTime.parse(node.getElement('dateOrigine')!.innerText),
    replacementDate: DateTime.parse(node.getElement('dateRemplacement')!.innerText),
    description: node.getElement('description')!.innerText,
  );

  /// Used to create [ReplacedDay] instance from a JSON file
  factory ReplacedDay.fromJson(Map<String, dynamic> map) => ReplacedDay(
    originalDate: DateTime.parse(map['originalDate'] as String),
    replacementDate: DateTime.parse(map['replacementDate'] as String),
    description: map['description'] as String,
  );

  Map<String, dynamic> toJson() => {
    'originalDate': originalDate.toString(),
    'replacementDate': replacementDate.toString(),
    'description': description,
  };

  @override
  String toString() {
    return 'ReplacedDay{'
        'originalDate: $originalDate, '
        'replacementDate: $replacementDate, '
        'description: $description}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplacedDay &&
          runtimeType == other.runtimeType &&
          originalDate == other.originalDate &&
          replacementDate == other.replacementDate &&
          description == other.description;

  @override
  int get hashCode => originalDate.hashCode ^ replacementDate.hashCode ^ description.hashCode;
}
