// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/signets_json_converters.dart';

part 'profile_student.freezed.dart';
part 'profile_student.g.dart';

/// Profile of the student
@freezed
abstract class ProfileStudent with _$ProfileStudent {
  const factory ProfileStudent({
    /// Balance of the student
    @JsonKey(name: 'soldeTotal') required String balance,

    /// First name of the student
    @TrimmedStringConverter() @JsonKey(name: 'prenom') required String firstName,

    /// Last name of the student
    @TrimmedStringConverter() @JsonKey(name: 'nom') required String lastName,

    /// Permanent code of the student (XXXX00000000)
    @JsonKey(name: 'codePerm') required String permanentCode,

    /// Universal code of the student (XX000000)
    @JsonKey(name: 'codeUniversel') @Default('') String universalCode,
  }) = _ProfileStudent;

  factory ProfileStudent.fromJson(Map<String, dynamic> json) => _$ProfileStudentFromJson(json);
}
