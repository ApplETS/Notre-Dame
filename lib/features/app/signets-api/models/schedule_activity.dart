// FLUTTER / DART / THIRD-PARTIES
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

/// Data-class that represent an activity of a course
class ScheduleActivity {
  // The course acronym (ex: "ABC123")
  final String courseAcronym;

  /// The group number of the activity (ex: "09")
  final String courseGroup;

  /// the location of the course
  final String courseTitle;

  /// The current day of the week (starting monday)
  /// for the ScheduleActivity (ex: 5 for friday)
  final int dayOfTheWeek;

  /// The current day of the week (ex: "Vendredi")
  final String day;

  /// Date when the activity start (no date part)
  final DateTime startTime;

  /// Date when the activity end (no date part)
  final DateTime endTime;

  //The code corresponding to the type of schedule activity
  final String activityCode;

  /// If the activity schedule is the main activity associated to the course (usually the )
  final bool isPrincipalActivity;

  /// the location of the activity
  final String activityLocation;

  /// the name of the activity
  final String name;

  ScheduleActivity(
      {required this.courseAcronym,
      required this.courseGroup,
      required this.courseTitle,
      required this.dayOfTheWeek,
      required this.day,
      required this.startTime,
      required this.endTime,
      required this.activityCode,
      required this.isPrincipalActivity,
      required this.activityLocation,
      required this.name});

  /// Used to create a new [CourseActivity] instance from a [XMLElement].
  factory ScheduleActivity.fromXmlNode(XmlElement node) => ScheduleActivity(
        courseAcronym: node.getElement('sigle')!.innerText,
        courseGroup: node.getElement('groupe')!.innerText,
        courseTitle: node.getElement('titreCours')!.innerText,
        dayOfTheWeek: int.parse(node.getElement('jour')!.innerText),
        day: node.getElement('journee')!.innerText,
        activityCode: node.getElement('codeActivite')!.innerText,
        name: node.getElement('nomActivite')!.innerText,
        isPrincipalActivity:
            node.getElement('activitePrincipale')!.innerText == "Oui",
        startTime:
            DateFormat('HH:mm').parse(node.getElement('heureDebut')!.innerText),
        endTime:
            DateFormat('HH:mm').parse(node.getElement('heureFin')!.innerText),
        activityLocation: node.getElement('local')!.innerText,
      );

  /// Used to create [CourseActivity] instance from a JSON file
  factory ScheduleActivity.fromJson(Map<String, dynamic> map) =>
      ScheduleActivity(
        courseAcronym: map['courseAcronym'] as String,
        courseGroup: map['courseGroup'] as String,
        courseTitle: map['courseTitle'] as String,
        dayOfTheWeek: int.parse(map['dayOfTheWeek'] as String),
        day: map['day'] as String,
        activityCode: map['activityCode'] as String,
        name: map['name'] as String,
        isPrincipalActivity:
            (map['isPrincipalActivity'] as String) == true.toString(),
        startTime: DateFormat('HH:mm').parse(map['startTime'] as String),
        endTime: DateFormat('HH:mm').parse(map['endTime'] as String),
        activityLocation: map['activityLocation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'courseAcronym': courseAcronym,
        'courseGroup': courseGroup,
        'courseTitle': courseTitle,
        'dayOfTheWeek': dayOfTheWeek.toString(),
        'day': day,
        'activityCode': activityCode,
        'name': name,
        'isPrincipalActivity': isPrincipalActivity.toString(),
        'startTime': DateFormat("HH:mm").format(startTime),
        'endTime': DateFormat("HH:mm").format(endTime),
        'activityLocation': activityLocation
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleActivity &&
          courseAcronym == other.courseAcronym &&
          courseGroup == other.courseGroup &&
          courseTitle == other.courseTitle &&
          dayOfTheWeek == other.dayOfTheWeek &&
          day == other.day &&
          activityCode == other.activityCode &&
          name == other.name &&
          isPrincipalActivity == other.isPrincipalActivity &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          activityLocation == other.activityLocation;

  @override
  int get hashCode =>
      courseAcronym.hashCode ^
      courseGroup.hashCode ^
      courseTitle.hashCode ^
      dayOfTheWeek.hashCode ^
      day.hashCode ^
      activityCode.hashCode ^
      name.hashCode ^
      isPrincipalActivity.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      activityLocation.hashCode;
}
