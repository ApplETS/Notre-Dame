// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/signets_json_converters.dart';

part 'course_activity.freezed.dart';
part 'course_activity.g.dart';

/// Activity (class session) of a course
@freezed
abstract class CourseActivity with _$CourseActivity {
  const factory CourseActivity({
    /// Course acronym and group (ex: LOG430-02)
    @JsonKey(name: 'coursGroupe') required String courseGroup,

    /// Course name
    @JsonKey(name: 'libelleCours') required String courseName,

    /// Activity name (ex: "Labo A")
    @JsonKey(name: 'nomActivite') required String activityName,

    /// Description of the activity (ex: "Laboratoire (Groupe A)")
    @JsonKey(name: 'descriptionActivite') required String activityDescription,

    /// Places where the activity is given
    @LocationListConverter() @JsonKey(name: 'local') required List<String> activityLocation,

    /// Date when the activity start
    @JsonKey(name: 'dateDebut') required DateTime startDateTime,

    /// Date when the activity end
    @JsonKey(name: 'dateFin') required DateTime endDateTime,
  }) = _CourseActivity;

  factory CourseActivity.fromJson(Map<String, dynamic> json) => _$CourseActivityFromJson(json);
}
