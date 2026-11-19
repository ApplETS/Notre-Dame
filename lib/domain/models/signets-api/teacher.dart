// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/signets_json_converters.dart';

part 'teacher.freezed.dart';
part 'teacher.g.dart';

/// Teacher in charge of an activity
@freezed
abstract class Teacher with _$Teacher {
  const factory Teacher({
    /// Last name of the teacher
    @JsonKey(name: 'nom') required String lastName,

    /// First name of the teacher
    @JsonKey(name: 'prenom') required String firstName,

    /// Email of the teacher
    @JsonKey(name: 'courriel') @Default('') String email,

    /// Office of the teacher (ex: B-2325)
    @JsonKey(name: 'localBureau') @Default('') String office,

    /// Phone number of the teacher
    @JsonKey(name: 'telephone') @Default('') String phone,

    /// Is the teacher the main teacher of the activity
    @SignetsBoolConverter() @JsonKey(name: 'enseignantPrincipal') @Default(false) bool isMainTeacher,
  }) = _Teacher;

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);
}
