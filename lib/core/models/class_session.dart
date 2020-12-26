// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

/// Data-class that represent a activity of a course
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

  final DateTime startDateTime;

  final DateTime endDateTime;

  ClassSession(
      {@required this.courseGroup,
      @required this.courseName,
      @required this.activityName,
      @required this.activityDescription,
      @required this.activityLocation,
      @required this.startDateTime,
      @required this.endDateTime});

  ClassSession.fromMap(Map<String, dynamic> map)
      : courseGroup = map['coursGroupe'] as String,
        courseName = map['libelleCours'] as String,
        activityName = map['nomActivite'] as String,
        activityDescription = map['descriptionActivite'] as String,
        activityLocation = map['local'] as String,
        startDateTime = DateTime.parse(map['dateDebut'] as String),
        endDateTime = DateTime.parse(map['dateFin'] as String);

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
