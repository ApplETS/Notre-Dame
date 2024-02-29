// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/core/managers/storage_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/models/grade_graph_entry.dart';
import 'package:notredame/locator.dart';

/// Repository to access all the data related to courses taken by the student
class GradeGraphRepository {
  static const String tag = "GradeRepository";

  final Logger _logger = locator<Logger>();

  // Storage manager to read or write files in storage.
  final StorageManager _storageManager = locator<StorageManager>();

  /// To access the user currently logged
  final UserRepository _userRepository = locator<UserRepository>();

  String _getFileName() {
    return '${_userRepository.monETSUser.universalCode}-grades-progression-graph-data.json';
  }

  Future<bool> _fileExists() async {
    final File file = await _storageManager.getLocalFile(_getFileName());
    return file.exists();
  }

  Future<bool> _gradesJsonNotEmpty() async {
    final String gradesJSON = await _storageManager.readFile(_getFileName());
    return gradesJSON.isNotEmpty;
  }

  Future<List<GradeGraphEntry>> getGradesForCourse(
      String courseAcronym, String group, String session) async {
    final List<GradeGraphEntry> grades = await _getGrades();

    return grades
        .where((course) =>
            course.acronym == courseAcronym &&
            course.group == group &&
            course.session == session)
        .toList();
  }

  Future<List<GradeGraphEntry>> _getGrades() async {
    List<GradeGraphEntry> grades = <GradeGraphEntry>[];

    if (await _fileExists()) {
      final String gradesProgressionJSON =
          await _storageManager.readFile(_getFileName());

      grades = (jsonDecode(gradesProgressionJSON) as List)
          .map((grade) =>
              GradeGraphEntry.fromJson(grade as Map<String, dynamic>))
          .toList();
    }

    return grades;
  }

  Future<File> updateGradeEntry(Course course) async {
    final String fileName = _getFileName();
    final List<GradeGraphEntry> grades = await _getGrades();
    grades.add(_generateNewEntry(course));
    
    File result;
    try {
      result = await _writeGradesToFile(fileName, grades);
    } catch (e) {
      _logger.e("- writeGradesToStorage: Failed to write file to storage: $e");
    }

    _logger.d(
        "- writeGradesToStorage: Grades Graph Entry written to file.  Path: ${result.path}");

    return result;
  }

  Future<bool> isGradeNew(Course course) async {
    bool isGradeNew = true;

    if (course.summary != null) {
      final courseGrades = await getGradesForCourse(
          course.acronym, course.group, course.session);

      if (courseGrades.isNotEmpty) {
        for (final entry in courseGrades) {
          isGradeNew = course.summary.currentMarkInPercent !=
              entry.summary.currentMarkInPercent;
        }
      }
    }

    return isGradeNew;
  }

  GradeGraphEntry _generateNewEntry(Course course) {
    return GradeGraphEntry(
        course.acronym, course.group, course.session, course.summary);
  }

  /// Sort grades by session > acronym > group > time
  int _gradeSortAlgorithm(GradeGraphEntry a, GradeGraphEntry b) {
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

  Future<File> _writeGradesToFile(
      String fileName, List<GradeGraphEntry> grades) {
    grades.sort((a, b) => _gradeSortAlgorithm(a, b));
    return _storageManager.writeToFile(fileName, jsonEncode(grades));
  }
}
