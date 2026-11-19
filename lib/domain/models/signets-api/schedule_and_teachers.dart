// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/schedule_activity.dart';
import 'package:notredame/domain/models/signets-api/teacher.dart';

part 'schedule_and_teachers.freezed.dart';
part 'schedule_and_teachers.g.dart';

/// Weekly schedule of the student with the teachers in charge of the activities
@freezed
abstract class ScheduleAndTeachers with _$ScheduleAndTeachers {
  const factory ScheduleAndTeachers({
    /// Activities of the schedule
    @JsonKey(name: 'listeActivites') @Default(<ScheduleActivity>[]) List<ScheduleActivity> activities,

    /// Teachers in charge of the activities
    @JsonKey(name: 'listeEnseignants') @Default(<Teacher>[]) List<Teacher> teachers,
  }) = _ScheduleAndTeachers;

  factory ScheduleAndTeachers.fromJson(Map<String, dynamic> json) => _$ScheduleAndTeachersFromJson(json);
}
