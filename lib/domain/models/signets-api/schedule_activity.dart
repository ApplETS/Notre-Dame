// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/signets_json_converters.dart';

part 'schedule_activity.freezed.dart';
part 'schedule_activity.g.dart';

/// Recurring activity in the weekly schedule of the student
@freezed
abstract class ScheduleActivity with _$ScheduleActivity {
  const factory ScheduleActivity({
    /// The course acronym (ex: "ABC123")
    @JsonKey(name: 'sigle') required String courseAcronym,

    /// The title of the course
    @JsonKey(name: 'titreCours') required String courseTitle,

    /// The day of the week (starting monday) for the activity (ex: 5 for friday)
    @SignetsIntOrZeroConverter() @JsonKey(name: 'jour') required int dayOfTheWeek,

    /// Time when the activity start (no date part)
    @HourMinuteConverter() @JsonKey(name: 'heureDebut') required DateTime startTime,

    /// Time when the activity end (no date part)
    @HourMinuteConverter() @JsonKey(name: 'heureFin') required DateTime endTime,

    /// The code corresponding to the type of activity
    @JsonKey(name: 'codeActivite') required String activityCode,
  }) = _ScheduleActivity;

  factory ScheduleActivity.fromJson(Map<String, dynamic> json) => _$ScheduleActivityFromJson(json);
}
