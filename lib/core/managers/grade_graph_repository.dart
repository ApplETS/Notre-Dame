// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/core/managers/storage_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/models/grade_progression_entry.dart';
import 'package:notredame/locator.dart';

/// Repository to access the grades progression graph data.
class GradeGraphRepository {
  static const String tag = "GradeRepository";

  final Logger _logger = locator<Logger>();

  // Storage manager to read or write files in storage.
  final StorageManager _storageManager = locator<StorageManager>();

  /// To access the user currently logged
  final UserRepository _userRepository = locator<UserRepository>();

  /// Get the name of the grades progression graph data JSON file.
  String _getFileName() {
    return '${_userRepository.monETSUser.universalCode}-grades-progression-graph-data.json';
  }

  /// Gets the grade for the course with the same [courseAcronym], [group] and [session].
  Future<List<GradeProgressionEntry>> getGradesForCourse(
      String courseAcronym, String group, String session) async {
    final List<GradeProgressionEntry> grades = await _getGrades();

    return grades
        .where((course) =>
            course.acronym == courseAcronym &&
            course.group == group &&
            course.session == session)
        .toList();
  }

  /// Get the grades progression graph data from the storage.
  Future<List<GradeProgressionEntry>> _getGrades() async {
    List<GradeProgressionEntry> grades = <GradeProgressionEntry>[];

    if (await _storageManager.fileExists(_getFileName())) {
      final String gradesProgressionJSON =
          await _storageManager.readFile(_getFileName());

      grades = (jsonDecode(gradesProgressionJSON) as List)
          .map((grade) =>
              GradeProgressionEntry.fromJson(grade as Map<String, dynamic>))
          .toList();
    }

    return grades;
  }

  /// Update the grades progression graph data with the new [course].
  Future<File> updateGradesProgressionData(Course course) async {
    final List<GradeProgressionEntry> grades = await _getGrades();
    final GradeProgressionEntry newEntry = GradeProgressionEntry(
        course.acronym, course.group, course.session, course.summary);

    grades.add(newEntry);

    File result;
    try {
      result = await _writeGradesToFile(grades);
    } catch (e) {
      _logger.e("- writeGradesToStorage: Failed to write file to storage: $e");
    }

    _logger.d(
        "- writeGradesToStorage: Grades Graph Entry written to file.  Path: ${result.path}");

    return result;
  }

  /// Check if the grade for the [course] is new.
  Future<bool> isGradeNew(Course course) async {
    bool isGradeNew = true;

    if (course.summary != null) {
      final courseGrades = await getGradesForCourse(
          course.acronym, course.group, course.session);

      if (courseGrades.isNotEmpty) {
        for (final entry in courseGrades) {
          if (course.summary.currentMarkInPercent ==
              entry.summary.currentMarkInPercent) {
            isGradeNew = false;
          }
        }
      }
    }

    return isGradeNew;
  }

  /// Sort grades by session > acronym > group > time
  int gradeSortAlgorithm(GradeProgressionEntry a, GradeProgressionEntry b) {
    final int sessionComparison = a.session.compareTo(b.session);
    if (sessionComparison != 0) {
      return sessionComparison;
    }

    final int acronymComparison = a.acronym.compareTo(b.acronym);
    if (acronymComparison != 0) {
      return acronymComparison;
    }

    final int groupComparison = a.group.compareTo(b.group);
    if (groupComparison != 0) {
      return groupComparison;
    }

    final int timeComparison = a.timestamp.compareTo(b.timestamp);
    return timeComparison;
  }

  /// Write the grades to the storage.
  Future<File> _writeGradesToFile(List<GradeProgressionEntry> grades) {
    grades.sort((a, b) => gradeSortAlgorithm(a, b));

    return _storageManager.writeToFile(_getFileName(), jsonEncode(grades));
  }
}
