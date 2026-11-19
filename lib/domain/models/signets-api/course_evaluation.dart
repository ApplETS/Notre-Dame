// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/signets_json_converters.dart';

part 'course_evaluation.freezed.dart';
part 'course_evaluation.g.dart';

/// Evaluation (exam, homework, ...) which happened during a course
@freezed
abstract class CourseEvaluation with _$CourseEvaluation {
  // ignore: unused_element to create methods
  const CourseEvaluation._();

  const factory CourseEvaluation({
    /// Course acronym and group (ex: LOG430-02)
    @JsonKey(name: 'coursGroupe') required String courseGroup,

    /// Title of the evaluation (ex: Laboratoire 1)
    @JsonKey(name: 'nom') required String title,

    /// Weight of the evaluation on the course (ex: 12.5)
    @SignetsDoubleOrZeroConverter() @JsonKey(name: 'ponderation') required double weight,

    /// Is the mark of the evaluation published
    @SignetsBoolConverter() @JsonKey(name: 'publie') required bool published,

    /// Message given by the teacher
    @TrimmedStringConverter() @JsonKey(name: 'messageDuProf') @Default('') String teacherMessage,

    /// Is this evaluation ignored in the final grade
    @SignetsBoolConverter() @JsonKey(name: 'ignoreDuCalcul') required bool ignore,

    /// On how much the evaluation is corrected included bonus (ex: 30.0+20)
    @DecimalStringConverter() @JsonKey(name: 'corrigeSur') required String correctedEvaluationOutOf,

    /// Mark obtained by the student on the evaluation (ex: 24)
    @SignetsDoubleConverter() @JsonKey(name: 'note') double? mark,

    /// Average mark of the students on this evaluation (ex: 30)
    @SignetsDoubleConverter() @JsonKey(name: 'moyenne') double? passMark,

    /// Standard deviation of the evaluation
    @SignetsDoubleConverter() @JsonKey(name: 'ecartType') double? standardDeviation,

    /// Median of the evaluation
    @SignetsDoubleConverter() @JsonKey(name: 'mediane') double? median,

    /// Percentile rank of the student on this evaluation
    @SignetsIntConverter() @JsonKey(name: 'rangCentile') int? percentileRank,

    /// Date on which the evaluation should happen (can also be the date on which
    /// the mark was enter in the system)
    @NullableDateTimeConverter() @JsonKey(name: 'dateCible') DateTime? targetDate,
  }) = _CourseEvaluation;

  factory CourseEvaluation.fromJson(Map<String, dynamic> json) => _$CourseEvaluationFromJson(json);

  /// On how much the evaluation is corrected, without the bonus (ex: 30)
  double get correctedEvaluationOutOfFormatted => correctedEvaluationOutOf.isNotEmpty
      ? double.tryParse(correctedEvaluationOutOf.split('+').first.replaceAll(',', '.')) ?? 0.0
      : 0.0;

  double get markInPercent => mark! / correctedEvaluationOutOfFormatted;

  /// Weighted grade of the evaluation
  /// (ex: Mark of 25/50 and 10% weight => 5/10 weighted grade)
  double? get weightedGrade => mark == null || correctedEvaluationOutOfFormatted == 0.0 || weight == 0.0
      ? null
      : (mark! / correctedEvaluationOutOfFormatted) * weight;
}
