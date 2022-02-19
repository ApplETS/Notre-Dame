import 'package:flutter/foundation.dart';

class GradesWidgetData {
  static const String KEY_PREFIX = "grade_";

  List<String> courseAcronyms;
  List<String> grades;
  String title;

  GradesWidgetData({
    @required this.title,
    @required this.courseAcronyms,
    @required this.grades,
  });
}

class ProgressWidgetData {
  static const String KEY_PREFIX = "progress_";

  String title;
  double progress;
  int elapsedDays;
  int totalDays;
  String suffix;

  ProgressWidgetData({
    @required this.title,
    @required this.progress,
    @required this.elapsedDays,
    @required this.totalDays,
    @required this.suffix
  });
}
