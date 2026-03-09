// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_activity.freezed.dart';
part 'course_activity.g.dart';

@freezed
abstract class CourseActivity with _$CourseActivity {
  // ignore: unused_element to create methods
  const CourseActivity._();

  const factory CourseActivity({
    /// Start date
    @JsonKey(name: 'dateDebut') required DateTime startDate,

    /// End date
    @JsonKey(name: 'dateFin') required DateTime endDate,

    /// Course code (like CHM131-06)
    @JsonKey(name: 'coursGroupe') required String courseGroup,

    /// Place where the activity given (ex: "B-1404")
    @JsonKey(name: 'local') required String location,
    
    /// Description of the activity (ex: "Labo A")
    @JsonKey(name: 'nomActivite') required String activityName,

    /// Activity description (ex: "Laboratoire (Groupe A)")
    @JsonKey(name: 'descriptionActivite') required String description,

    /// Course name (ex: "Chimie et matériaux")
    @JsonKey(name: 'libelleCours') required String courseLabel,
  }) = _CourseActivity;

  factory CourseActivity.fromJson(Map<String, dynamic> json) => _$CourseActivityFromJson(json);
}
