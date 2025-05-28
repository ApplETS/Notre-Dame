// FLUTTER / DART / THIRD-PARTIES

// Package imports:
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

/// Data-class that represent an activity of a course
class ScheduleActivity {
  // The course acronym (ex: "ABC123")
  final String courseAcronym;

  /// the location of the course
  final String courseTitle;

  /// The current day of the week (starting monday)
  /// for the ScheduleActivity (ex: 5 for friday)
  final int dayOfTheWeek;

  /// Date when the activity start (no date part)
  final DateTime startTime;

  /// Date when the activity end (no date part)
  final DateTime endTime;

  //The code corresponding to the type of schedule activity
  final String activityCode;

  ScheduleActivity({
    required this.courseAcronym,
    required this.courseTitle,
    required this.dayOfTheWeek,
    required this.startTime,
    required this.endTime,
    required this.activityCode
  });

  /// Used to create a new [CourseActivity] instance from a [XMLElement].
  factory ScheduleActivity.fromXmlNode(XmlElement node) => ScheduleActivity(
    courseAcronym: node.getElement('sigle')!.innerText,
    courseTitle: node.getElement('titreCours')!.innerText,
    dayOfTheWeek: int.parse(node.getElement('jour')!.innerText),
    startTime: DateFormat('HH:mm').parse(node.getElement('heureDebut')!.innerText),
    endTime: DateFormat('HH:mm').parse(node.getElement('heureFin')!.innerText),
    activityCode: node.getElement('codeActivite')!.innerText,
  );

  /// Used to create [CourseActivity] instance from a JSON file
  factory ScheduleActivity.fromJson(Map<String, dynamic> map) => ScheduleActivity(
    courseAcronym: map['courseAcronym'] as String,
    courseTitle: map['courseTitle'] as String,
    dayOfTheWeek: int.parse(map['dayOfTheWeek'] as String),
    startTime: DateFormat('HH:mm').parse(map['startTime'] as String),
    endTime: DateFormat('HH:mm').parse(map['endTime'] as String),
    activityCode: map['activityCode'] as String,
  );

  Map<String, dynamic> toJson() => {
    'courseAcronym': courseAcronym,
    'courseTitle': courseTitle,
    'dayOfTheWeek': dayOfTheWeek.toString(),
    'startTime': DateFormat("HH:mm").format(startTime),
    'endTime': DateFormat("HH:mm").format(endTime),
    'activityCode': activityCode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleActivity &&
          courseAcronym == other.courseAcronym &&
          courseTitle == other.courseTitle &&
          dayOfTheWeek == other.dayOfTheWeek &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          activityCode == other.activityCode;

  @override
  int get hashCode =>
      courseAcronym.hashCode ^
      courseTitle.hashCode ^
      dayOfTheWeek.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      activityCode.hashCode;
}
