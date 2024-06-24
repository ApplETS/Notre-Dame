// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/signets_errors.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/api_exception.dart';
import 'package:notredame/utils/locator.dart';

class GradesDetailsViewModel extends FutureViewModel<Course> {
  /// Used to get the courses of the student
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Used to get the current course selected of the student
  Course course;

  GradesDetailsViewModel({required this.course, required AppIntl intl})
      : _appIntl = intl;

  @override
  Future<Course> futureToRun() async {
    try {
      setBusyForObject(course, true);
      course = await _courseRepository.getCourseSummary(course);
      notifyListeners();
    } catch (e) {
      onError(e);
    } finally {
      setBusyForObject(course, false);
    }
    return course;
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    if (error is ApiException) {
      if (error.message.startsWith(SignetsError.gradesNotAvailable) ||
          error.errorCode == SignetsError.gradesEmpty) {
        Fluttertoast.showToast(msg: _appIntl.grades_msg_no_grade);
      } else {
        Fluttertoast.showToast(msg: _appIntl.error);
      }
    }
  }

  Future<bool> refresh() async {
    try {
      setBusyForObject(course, true);
      course = await _courseRepository.getCourseSummary(course);
      notifyListeners();
      return true;
    } catch (error) {
      onError(error);
      return false;
    } finally {
      setBusyForObject(course, false);
    }
  }

  /// Start the discovery process of this page if needed
  static Future<void> startDiscovery(BuildContext context) async {
    final SettingsManager settingsManager = locator<SettingsManager>();
    if (await settingsManager.getBool(PreferencesFlag.discoveryGradeDetails) ==
        null) {
      if (!context.mounted) return;
      final List<String> ids = findDiscoveriesByGroupName(
              context, DiscoveryGroupIds.pageGradeDetails)
          .map((e) => e.featureId)
          .toList();

      Future.delayed(const Duration(seconds: 1),
          () => FeatureDiscovery.discoverFeatures(context, ids));

      settingsManager.setBool(PreferencesFlag.discoveryGradeDetails, true);
    }
  }
}
