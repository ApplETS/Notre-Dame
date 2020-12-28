// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

/// Data-class that represent an activity of a course
class ClassSession {
  /// Course acronym and group
  /// Presented like: acronym-group (ex: LOG430-02)
  final String courseGroup;

  /// Course name
  final String courseName;

  /// Activity name (ex: "Labo A")
  final String activityName;

  /// Description of the activity
  /// (ex: "Laboratoire (Groupe A)")
  final String activityDescription;

  /// Place where the activity is given
  final String activityLocation;

  /// Date when the activity start
  final DateTime startDateTime;

  /// Date when the activity end
  final DateTime endDateTime;

  ClassSession(
      {@required this.courseGroup,
      @required this.courseName,
      @required this.activityName,
      @required this.activityDescription,
      @required this.activityLocation,
      @required this.startDateTime,
      @required this.endDateTime});

  /// Used to create a new [ClassSession] instance from a [XMLElement].
  factory ClassSession.fromXmlNode(XmlElement node) => ClassSession(
      courseGroup: node.getElement('coursGroupe').innerText,
      courseName: node.getElement('libelleCours').innerText,
      activityName: node.getElement('nomActivite').innerText,
      activityDescription: node.getElement('descriptionActivite').innerText,
      activityLocation: node.getElement('local').innerText,
      startDateTime: DateTime.parse(node.getElement('dateDebut').innerText),
      endDateTime: DateTime.parse(node.getElement('dateFin').innerText));

  /// Used to create [ClassSession] instance from a JSON file
  factory ClassSession.fromJson(Map<String, dynamic> map) => ClassSession(
      courseGroup: map['courseGroup'] as String,
      courseName: map['courseName'] as String,
      activityName: map['activityName'] as String,
      activityDescription: map['activityDescription'] as String,
      activityLocation: map['activityLocation'] as String,
      startDateTime: DateTime.parse(map['startDateTime'] as String),
      endDateTime: DateTime.parse(map['endDateTime'] as String));

  Map<String, dynamic> toJson() => {
        'courseGroup': courseGroup,
        'courseName': courseName,
        'activityName': activityName,
        'activityDescription': activityDescription,
        'activityLocation': activityLocation,
        'startDateTime': startDateTime,
        'endDateTime': endDateTime
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassSession &&
          runtimeType == other.runtimeType &&
          courseGroup == other.courseGroup &&
          courseName == other.courseName &&
          activityName == other.activityName &&
          activityDescription == other.activityDescription &&
          activityLocation == other.activityLocation &&
          startDateTime == other.startDateTime &&
          endDateTime == other.endDateTime;

  @override
  int get hashCode =>
      courseGroup.hashCode ^
      courseName.hashCode ^
      activityName.hashCode ^
      activityDescription.hashCode ^
      activityLocation.hashCode ^
      startDateTime.hashCode ^
      endDateTime.hashCode;
}
