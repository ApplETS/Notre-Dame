// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

/// Data-class that represent a course evaluation.
class CourseEvaluation {
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

  CourseEvaluation(
      {@required this.acronym,
      @required this.group,
      @required this.teacherName,
      @required this.type,
      @required this.startAt,
      @required this.endAt,
      @required this.isCompleted});

  /// Used to create a new [CourseEvaluation] instance from a [XMLElement].
  factory CourseEvaluation.fromXmlNode(XmlElement node) => CourseEvaluation(
      acronym: node.getElement('Sigle').innerText,
      group: node.getElement('Groupe').innerText,
      teacherName: node.getElement('Enseignant').innerText,
      type: node.getElement('TypeEvaluation').innerText,
      startAt:
          DateTime.tryParse(node.getElement('DateDebutEvaluation').innerText),
      endAt: DateTime.tryParse(node.getElement('DateFinEvaluation').innerText),
      isCompleted:
          node.getElement('EstComplete').innerText.toLowerCase() == 'true');

  /// Used to create [CourseEvaluation] instance from a JSON file
  factory CourseEvaluation.fromJson(Map<String, dynamic> map) =>
      CourseEvaluation(
          acronym: map['acronym'] as String,
          group: map['group'] as String,
          teacherName: map['teacherName'] as String,
          type: map['type'] as String,
          startAt: DateTime.tryParse(map['startAt'] as String),
          endAt: DateTime.tryParse(map['endAt'] as String),
          isCompleted: map['isCompleted'] as bool);

  Map<String, dynamic> toJson() => {
        'acronym': acronym,
        'group': group,
        'teacherName': teacherName,
        'type': type,
        'startAt': startAt?.toString(),
        'endAt': endAt?.toString(),
        'isCompleted': isCompleted,
      };

  @override
  String toString() {
    return 'CourseEvaluation{'
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
      other is CourseEvaluation &&
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
