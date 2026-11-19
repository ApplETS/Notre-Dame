// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'program.freezed.dart';
part 'program.g.dart';

/// Program in which the student is (or was) registered
@freezed
abstract class Program with _$Program {
  const factory Program({
    /// Name of the program
    @JsonKey(name: 'libelle') required String name,

    /// Code of the program (ex: 0725)
    @JsonKey(name: 'code') required String code,

    /// Average grade of the program (x.xx / 4.30)
    @JsonKey(name: 'moyenne') required String average,

    /// Number of accumulated credits for the program
    @JsonKey(name: 'nbCreditsCompletes') required String accumulatedCredits,

    /// Number of registered credits for the program
    @JsonKey(name: 'nbCreditsInscrits') required String registeredCredits,

    /// Number of completed courses for the program
    @JsonKey(name: 'nbCrsReussis') required String completedCourses,

    /// Number of failed courses for the program
    @JsonKey(name: 'nbCrsEchoues') required String failedCourses,

    /// Number of equivalent courses for the program
    @JsonKey(name: 'nbEquivalences') required String equivalentCourses,

    /// Status of the program (Actif, Diplome)
    @JsonKey(name: 'statut') required String status,
  }) = _Program;

  factory Program.fromJson(Map<String, dynamic> json) => _$ProgramFromJson(json);
}
