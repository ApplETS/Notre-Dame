// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/course_evaluation.dart';
import 'package:notredame/domain/models/signets-api/signets_json_converters.dart';

part 'course_summary.freezed.dart';
part 'course_summary.g.dart';

/// Current mark, score, ... of a course
@freezed
abstract class CourseSummary with _$CourseSummary {
  const factory CourseSummary({
    /// Mark obtained by the student in percent (ex: 24)
    @SignetsDoubleConverter() @JsonKey(name: 'noteACeJour') required double? currentMarkInPercent,

    /// On how much the course is actually corrected (ex: 30)
    /// Sum of all the evaluations weight already published.
    @SignetsDoubleOrZeroConverter() @JsonKey(name: 'tauxPublication') required double markOutOf,

    /// All the evaluations for this courses.
    @JsonKey(name: 'liste') @Default(<CourseEvaluation>[]) List<CourseEvaluation> evaluations,

    /// Mark obtained by the student (ex: 24)
    @SignetsDoubleConverter() @JsonKey(name: 'scoreFinalSur100') double? currentMark,

    /// Average mark of the class (ex: 30)
    @SignetsDoubleConverter() @JsonKey(name: 'moyenneClasse') double? passMark,

    /// Standard deviation of the class
    @SignetsDoubleConverter() @JsonKey(name: 'ecartTypeClasse') double? standardDeviation,

    /// Median of the class
    @SignetsDoubleConverter() @JsonKey(name: 'medianeClasse') double? median,

    /// Percentile rank of the student on this course
    @SignetsIntConverter() @JsonKey(name: 'rangCentileClasse') int? percentileRank,
  }) = _CourseSummary;

  factory CourseSummary.fromJson(Map<String, dynamic> json) => _$CourseSummaryFromJson(json);
}
