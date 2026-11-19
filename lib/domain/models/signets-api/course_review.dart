// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/signets_json_converters.dart';

part 'course_review.freezed.dart';
part 'course_review.g.dart';

/// Course evaluation (review) the student is asked to fill.
@freezed
abstract class CourseReview with _$CourseReview {
  const factory CourseReview({
    /// Course acronym (ex: LOG430)
    @JsonKey(name: 'Sigle') required String acronym,

    /// Course group, on which group the student is registered
    @JsonKey(name: 'Groupe') required String group,

    /// Name of the professor
    @JsonKey(name: 'Enseignant') required String teacherName,

    /// Type of the evaluation
    @JsonKey(name: 'TypeEvaluation') required String type,

    /// Date when the evaluation start.
    @JsonKey(name: 'DateDebutEvaluation') required DateTime startAt,

    /// When the evaluation end.
    @JsonKey(name: 'DateFinEvaluation') required DateTime endAt,

    /// Is the evaluation completed
    @SignetsBoolConverter() @JsonKey(name: 'EstComplete') required bool isCompleted,
  }) = _CourseReview;

  factory CourseReview.fromJson(Map<String, dynamic> json) => _$CourseReviewFromJson(json);
}
