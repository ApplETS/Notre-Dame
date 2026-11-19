// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/course_review.dart';
import 'package:notredame/domain/models/signets-api/course_summary.dart';
import 'package:notredame/domain/models/signets-api/signets_json_converters.dart';

part 'course.freezed.dart';
part 'course.g.dart';

/// Course taken by the student
@freezed
abstract class Course with _$Course {
  // ignore: unused_element to create methods
  const Course._();

  const factory Course({
    /// Course acronym (ex: LOG430)
    @JsonKey(name: 'sigle') required String acronym,

    /// Title of the course (ex: Chimie et matériaux)
    @JsonKey(name: 'titreCours') required String title,

    /// Course group, on which group the student is registered
    @JsonKey(name: 'groupe') required String group,

    /// Session short name during which the course is given (ex: H2020)
    @JsonKey(name: 'session') required String session,

    /// Code number of the program of which the course is a part of
    @JsonKey(name: 'programmeEtudes') required String programCode,

    /// Number of credits of the course
    @SignetsIntOrZeroConverter() @JsonKey(name: 'nbCredits') required int numberOfCredits,

    /// Final grade of the course (ex: A+, C, ...), null if the course doesn't have a grade yet.
    @EmptyStringAsNullConverter() @JsonKey(name: 'cote') String? grade,

    /// Current mark, score... of the student for this course.
    CourseSummary? summary,

    /// Information about when the course will be evaluated by the student.
    List<CourseReview>? reviews,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  /// Get the teacher name if available
  String? get teacherName => reviews?.first.teacherName;

  /// Determine if we are currently in the review period for this course.
  bool get inReviewPeriod {
    if (reviews == null) {
      return false;
    }

    final now = DateTime.now();

    return now.isAfter(reviews!.first.startAt) && now.isBefore(reviews!.first.endAt);
  }

  /// Determine if all the reviews of this course are completed.
  bool? get allReviewsCompleted {
    if (reviews == null) {
      return true;
    }

    final now = DateTime.now();
    final activeReviews = reviews!
        .where((review) => review.startAt.isBefore(now) && review.endAt.isAfter(now))
        .toList();

    return activeReviews.isNotEmpty && activeReviews.every((review) => review.isCompleted);
  }
}
