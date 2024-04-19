// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';

/// Manage the analytics of the application
class CourseGradeCacheService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  CourseGradeCacheService();

  void setCourseGradeCache(String semester, String courseCode,
      String courseName, double courseGrade) {
    _analytics.logEvent(name: "setCourseGradeCache");
  }
}

class SemesterCache {
  final String semester;
  final List<GradeCache> gradeCacheList;

  SemesterCache({this.semester, this.gradeCacheList});

  factory SemesterCache.fromJson(Map<String, dynamic> json) {
    return SemesterCache(
      semester: json['semester'] as String,
      gradeCacheList: (json['gradeCacheList'] as List<dynamic>)
          .map((e) => GradeCache.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'semester': semester,
        'gradeCacheList': gradeCacheList.map((e) => e.toJson()),
      };
}

class GradeCache {
  final String courseCode;
  final String courseName;
  final double courseGrade;

  GradeCache({this.courseCode, this.courseName, this.courseGrade});

  factory GradeCache.fromJson(Map<String, dynamic> json) {
    return GradeCache(
      courseCode: json['courseCode'] as String,
      courseName: json['courseName'] as String,
      courseGrade: json['courseGrade'] as double,
    );
  }

  Map<String, dynamic> toJson() => {
        'courseCode': courseCode,
        'courseName': courseName,
        'courseGrade': courseGrade,
      };
}
