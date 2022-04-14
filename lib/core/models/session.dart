// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

/// Data-class that represent a session of courses.
class Session {
  /// Short name of the session (like H2020)
  final String shortName;

  /// Complete name of the session (like Hiver 2020)
  final String name;

  /// Start date of the session, date when the first course is given
  final DateTime startDate;

  /// End date of the session
  final DateTime endDate;

  /// End date of the courses for this session, date when the last course is given
  final DateTime endDateCourses;

  /// Date when the registration for the session start.
  final DateTime startDateRegistration;

  /// Date when the registration for the session end.
  final DateTime deadlineRegistration;

  /// Date when the cancellation of a course with refund start
  final DateTime startDateCancellationWithRefund;

  /// Date when the cancellation of a course with refund end
  final DateTime deadlineCancellationWithRefund;

  /// Date when the cancellation of a course with refund end for the new students
  final DateTime deadlineCancellationWithRefundNewStudent;

  /// Date when the cancellation of a course without refund start for the new students
  final DateTime startDateCancellationWithoutRefundNewStudent;

  /// Date when the cancellation of a course without refund end for the new students
  final DateTime deadlineCancellationWithoutRefundNewStudent;

  /// Date when the cancellation of the ASEQ end.
  final DateTime deadlineCancellationASEQ;

  Session(
      {@required this.shortName,
      @required this.name,
      @required this.startDate,
      @required this.endDate,
      @required this.endDateCourses,
      @required this.startDateRegistration,
      @required this.deadlineRegistration,
      @required this.startDateCancellationWithRefund,
      @required this.deadlineCancellationWithRefund,
      @required this.deadlineCancellationWithRefundNewStudent,
      @required this.startDateCancellationWithoutRefundNewStudent,
      @required this.deadlineCancellationWithoutRefundNewStudent,
      @required this.deadlineCancellationASEQ});

  /// Create a new [Session] instance from a [XMLElement] received from [SignetsApi]
  factory Session.fromXmlNode(XmlElement node) => Session(
      shortName: node.getElement("abrege").innerText,
      name: node.getElement("auLong").innerText,
      startDate: DateTime.parse(node.getElement("dateDebut").innerText),
      endDate: DateTime.parse(node.getElement("dateFin").innerText),
      endDateCourses: DateTime.parse(node.getElement("dateFinCours").innerText),
      startDateRegistration:
          DateTime.parse(node.getElement("dateDebutChemiNot").innerText),
      deadlineRegistration:
          DateTime.parse(node.getElement("dateFinChemiNot").innerText),
      startDateCancellationWithRefund: DateTime.parse(
          node.getElement("dateDebutAnnulationAvecRemboursement").innerText),
      deadlineCancellationWithRefund: DateTime.parse(
          node.getElement("dateFinAnnulationAvecRemboursement").innerText),
      deadlineCancellationWithRefundNewStudent: DateTime.parse(node
          .getElement("dateFinAnnulationAvecRemboursementNouveauxEtudiants")
          .innerText),
      startDateCancellationWithoutRefundNewStudent: DateTime.parse(node
          .getElement("dateDebutAnnulationSansRemboursementNouveauxEtudiants")
          .innerText),
      deadlineCancellationWithoutRefundNewStudent: DateTime.parse(node
          .getElement("dateFinAnnulationSansRemboursementNouveauxEtudiants")
          .innerText),
      deadlineCancellationASEQ: DateTime.parse(
          node.getElement("dateLimitePourAnnulerASEQ").innerText));

  /// Create a new [Session] instance from a JSON file
  factory Session.fromJson(Map<String, dynamic> json) => Session(
      shortName: json["shortName"] as String,
      name: json["name"] as String,
      startDate: DateTime.parse(json["startDate"] as String),
      endDate: DateTime.parse(json["endDate"] as String),
      endDateCourses: DateTime.parse(json["endDateCourses"] as String),
      startDateRegistration:
          DateTime.parse(json["startDateRegistration"] as String),
      deadlineRegistration:
          DateTime.parse(json["deadlineRegistration"] as String),
      startDateCancellationWithRefund:
          DateTime.parse(json["startDateCancellationWithRefund"] as String),
      deadlineCancellationWithRefund:
          DateTime.parse(json["deadlineCancellationWithRefund"] as String),
      deadlineCancellationWithRefundNewStudent: DateTime.parse(
          json["deadlineCancellationWithRefundNewStudent"] as String),
      startDateCancellationWithoutRefundNewStudent: DateTime.parse(
          json["startDateCancellationWithoutRefundNewStudent"] as String),
      deadlineCancellationWithoutRefundNewStudent: DateTime.parse(
          json["deadlineCancellationWithoutRefundNewStudent"] as String),
      deadlineCancellationASEQ:
          DateTime.parse(json["deadlineCancellationASEQ"] as String));

  Map<String, dynamic> toJson() => {
        'shortName': shortName,
        'name': name,
        'startDate': startDate.toString(),
        'endDate': endDate.toString(),
        'endDateCourses': endDateCourses.toString(),
        'startDateRegistration': startDateRegistration.toString(),
        'deadlineRegistration': deadlineRegistration.toString(),
        'startDateCancellationWithRefund':
            startDateCancellationWithRefund.toString(),
        'deadlineCancellationWithRefund':
            deadlineCancellationWithRefund.toString(),
        'deadlineCancellationWithRefundNewStudent':
            deadlineCancellationWithRefundNewStudent.toString(),
        'startDateCancellationWithoutRefundNewStudent':
            startDateCancellationWithoutRefundNewStudent.toString(),
        'deadlineCancellationWithoutRefundNewStudent':
            deadlineCancellationWithoutRefundNewStudent.toString(),
        'deadlineCancellationASEQ': deadlineCancellationASEQ.toString()
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          runtimeType == other.runtimeType &&
          shortName == other.shortName &&
          name == other.name &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          endDateCourses == other.endDateCourses &&
          startDateRegistration == other.startDateRegistration &&
          deadlineRegistration == other.deadlineRegistration &&
          startDateCancellationWithRefund ==
              other.startDateCancellationWithRefund &&
          deadlineCancellationWithRefund ==
              other.deadlineCancellationWithRefund &&
          deadlineCancellationWithRefundNewStudent ==
              other.deadlineCancellationWithRefundNewStudent &&
          startDateCancellationWithoutRefundNewStudent ==
              other.startDateCancellationWithoutRefundNewStudent &&
          deadlineCancellationWithoutRefundNewStudent ==
              other.deadlineCancellationWithoutRefundNewStudent &&
          deadlineCancellationASEQ == other.deadlineCancellationASEQ;

  @override
  int get hashCode =>
      shortName.hashCode ^
      name.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      endDateCourses.hashCode ^
      startDateRegistration.hashCode ^
      deadlineRegistration.hashCode ^
      startDateCancellationWithRefund.hashCode ^
      deadlineCancellationWithRefund.hashCode ^
      deadlineCancellationWithRefundNewStudent.hashCode ^
      startDateCancellationWithoutRefundNewStudent.hashCode ^
      deadlineCancellationWithoutRefundNewStudent.hashCode ^
      deadlineCancellationASEQ.hashCode;

  @override
  String toString() {
    return 'Session{shortName: $shortName, '
        'name: $name, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'endDateCourses: $endDateCourses, '
        'startDateRegistration: $startDateRegistration, '
        'deadlineRegistration: $deadlineRegistration, '
        'startDateCancellationWithRefund: $startDateCancellationWithRefund, '
        'deadlineCancellationWithRefund: $deadlineCancellationWithRefund, '
        'deadlineCancellationWithRefundNewStudent: $deadlineCancellationWithRefundNewStudent, '
        'startDateCancellationWithoutRefundNewStudent: $startDateCancellationWithoutRefundNewStudent, '
        'deadlineCancellationWithoutRefundNewStudent: $deadlineCancellationWithoutRefundNewStudent, '
        'deadlineCancellationASEQ: $deadlineCancellationASEQ}';
  }
}
