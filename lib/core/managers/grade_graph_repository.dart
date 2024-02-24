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

  Future<File> updateGradeEntry(String universalCode, Course course) async {
    List<GradeGraphEntry> grades = <GradeGraphEntry>[];
    final String fileName = '$universalCode-grades-progression-graph-data.json';
    final bool fileExists = await File(
            '${await _storageManager.getAppDocumentsDirectoryPath()}/$fileName')
        .exists();

    if (fileExists) {
      final String gradesProgressionJSON =
          await _storageManager.readFile(fileName);

      if (gradesProgressionJSON.isNotEmpty) {
        final List<GradeGraphEntry> oldGrades =
            (jsonDecode(gradesProgressionJSON) as List)
                .map((grade) =>
                    GradeGraphEntry.fromJson(grade as Map<String, dynamic>))
                .toList();
        grades = _refreshGradeEntry(oldGrades, course);
      } else {
        grades.add(_generateNewEntry(course));
      }
    } else {
      grades.add(_generateNewEntry(course));
    }
  String _getFileName() {
    return '${_userRepository.monETSUser.universalCode}-grades-progression-graph-data.json';
  }

    grades.sort((a, b) => _gradeSortAlgorithm(a, b));

    File result;
    try {
      result = await _storageManager.writeToFile(fileName, jsonEncode(grades));
    } catch (e) {
      _logger.e("- writeGradesToStorage: Failed to write file to storage: $e");
    }

    _logger.d(
        "- writeGradesToStorage: Grades Graph Entry written to file.  Path: ${result.path}");

    return result;
  }

  List<GradeGraphEntry> _refreshGradeEntry(
      List<GradeGraphEntry> grades, Course course) {
    if (course.summary != null) {
      bool courseFound = false;

      for (final entry in grades) {
        final bool sameCourse = course.acronym == entry.acronym &&
            course.group == entry.group &&
            course.session == entry.session;

        if (sameCourse) {
          courseFound = true;

          // Get all entries for this course
          final courseEntries = grades
              .where((courseEntry) =>
                  course.acronym == courseEntry.acronym &&
                  course.group == courseEntry.group &&
                  course.session == courseEntry.session)
              .toList();

          courseEntries.sort((a, b) {
            return a.timestamp.compareTo(b.timestamp);
          });

          final latestEntry = courseEntries.first;
          if (course.summary != latestEntry.summary) {
            _generateNewEntry(course);
          }
        }
      }

      if (!courseFound) {
        grades.add(_generateNewEntry(course));
      }
    }

    return grades;
  }

  Future<File> updateGradeEntries(
      String universalCode, List<Course> courses) async {
    List<GradeGraphEntry> grades;
    final String fileName = '$universalCode-grades-progression-graph-data.json';
    final bool fileExists = await File(
            '${await _storageManager.getAppDocumentsDirectoryPath()}/$fileName')
        .exists();

    if (fileExists) {
      List<GradeGraphEntry> oldGrades = <GradeGraphEntry>[];
      final String gradesProgressionJSON =
          await _storageManager.readFile(fileName);

      if (gradesProgressionJSON.isNotEmpty) {
        oldGrades = (jsonDecode(gradesProgressionJSON) as List<dynamic>)
            .cast<GradeGraphEntry>();

        for (final Course course in courses) {
          _refreshGradeEntry(oldGrades, course);
        }
      } else {
        grades = _generateGradesEntries(courses);
      }
    } else {
      grades = _generateGradesEntries(courses);
    }

    grades.sort((a, b) => _gradeSortAlgorithm(a, b));

    File result;
    try {
      result = await _storageManager.writeToFile(fileName, jsonEncode(grades));
    } catch (e) {
      _logger.e("- writeGradesToStorage: Failed to write file to storage $e");
    }

    _logger.d(
        "- writeGradesToStorage: Grades Graph Entry written to file. Path: ${result.path}");

    return result;
  }

  GradeGraphEntry _generateNewEntry(Course course) {
    return GradeGraphEntry(
        course.acronym, course.group, course.session, course.summary);
  }

  List<GradeGraphEntry> _generateGradesEntries(List<Course> courses) {
    final List<GradeGraphEntry> grades = <GradeGraphEntry>[];

    for (final course in courses) {
      if (course.summary != null) {
        grades.add(_generateNewEntry(course));
      }
    }

    return grades;
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
}
