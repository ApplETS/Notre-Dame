// FLUTTER / DART / THIRD-PARTIES
import 'package:xml/xml.dart';

/// Data-class that represent a course evaluation.
class CourseReview {
  /// Course acronym (ex: LOG430)
  final String acronym;

  /// Course group, on which group the student is registered
  final String group;

  /// Name of the professor
  final String teacherName;

  /// Date when the evaluation start.
  final DateTime startAt;

  /// When the evaluation end.
  final DateTime endAt;

  /// Type of the evaluation
  final String type;

  /// Is the evaluation completed
  final bool isCompleted;

  CourseReview(
      {required this.acronym,
      required this.group,
      required this.teacherName,
      required this.type,
      required this.startAt,
      required this.endAt,
      required this.isCompleted});

  /// Used to create a new [CourseReview] instance from a [XMLElement].
  factory CourseReview.fromXmlNode(XmlElement node) => CourseReview(
      acronym: node.getElement('Sigle')!.innerText,
      group: node.getElement('Groupe')!.innerText,
      teacherName: node.getElement('Enseignant')!.innerText,
      type: node.getElement('TypeEvaluation')!.innerText,
      startAt:
          DateTime.parse(node.getElement('DateDebutEvaluation')!.innerText),
      endAt: DateTime.parse(node.getElement('DateFinEvaluation')!.innerText),
      isCompleted:
          node.getElement('EstComplete')!.innerText.toLowerCase() == 'true');

  /// Used to create [CourseReview] instance from a JSON file
  factory CourseReview.fromJson(Map<String, dynamic> map) => CourseReview(
      acronym: map['acronym'] as String,
      group: map['group'] as String,
      teacherName: map['teacherName'] as String,
      type: map['type'] as String,
      startAt: DateTime.parse(map['startAt'] as String),
      endAt: DateTime.parse(map['endAt'] as String),
      isCompleted: map['isCompleted'] as bool);

  Map<String, dynamic> toJson() => {
        'acronym': acronym,
        'group': group,
        'teacherName': teacherName,
        'type': type,
        'startAt': startAt.toString(),
        'endAt': endAt.toString(),
        'isCompleted': isCompleted,
      };

  @override
  String toString() {
    return 'CourseReview{'
        'acronym: $acronym, '
        'group: $group, '
        'teacherName: $teacherName, '
        'type: $type, '
        'startAt: $startAt, '
        'endAt: $endAt, '
        'isCompleted: $isCompleted}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseReview &&
          runtimeType == other.runtimeType &&
          acronym == other.acronym &&
          group == other.group &&
          teacherName == other.teacherName &&
          startAt == other.startAt &&
          endAt == other.endAt &&
          type == other.type &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      acronym.hashCode ^
      group.hashCode ^
      teacherName.hashCode ^
      startAt.hashCode ^
      endAt.hashCode ^
      type.hashCode ^
      isCompleted.hashCode;
}
