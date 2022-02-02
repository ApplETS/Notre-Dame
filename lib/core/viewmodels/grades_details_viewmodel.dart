// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/core/utils/api_exception.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/discovery_ids.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/signets_errors.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';

// MANAGERS / SERVICES
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:signets_api_client/models.dart';

// OTHER
import 'package:notredame/locator.dart';

class GradesDetailsViewModel extends FutureViewModel<Course> {
  /// Used to get the courses of the student
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Used to get the current course selected of the student
  Course course;

  GradesDetailsViewModel({this.course, @required AppIntl intl})
      : _appIntl = intl;

  @override
  Future<Course> futureToRun() async {
    setBusyForObject(course, true);

    // ignore: return_type_invalid_for_catch_error
    await _courseRepository
        .getCourseSummary(course)
        // ignore: return_type_invalid_for_catch_error
        .catchError(onError)
        ?.then((value) {
      if (value != null) {
        course = value;
      }
    })?.whenComplete(() {
      setBusyForObject(course, false);
    });

    notifyListeners();

    return course;
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    if (error is ApiException && error.errorCode != SignetsError.gradesEmpty) {
      Fluttertoast.showToast(msg: _appIntl.error);
    }
  }

  Future<bool> refresh() async {
    try {
      setBusyForObject(course, true);
      await _courseRepository.getCourseSummary(course)?.then((value) {
        if (value != null) {
          course = value;
        }
      });
      notifyListeners();
      setBusyForObject(course, false);
      return true;
    } on Exception catch (error) {
      onError(error);
      setBusyForObject(course, false);
      return false;
    }
  }

  /// Start the discovery process of this page if needed
  static Future<void> startDiscovery(BuildContext context) async {
    final SettingsManager _settingsManager = locator<SettingsManager>();
    if (await _settingsManager.getBool(PreferencesFlag.discoveryGradeDetails) ==
        null) {
      final List<String> ids = findDiscoveriesByGroupName(
              context, DiscoveryGroupIds.pageGradeDetails)
          .map((e) => e.featureId)
          .toList();

      Future.delayed(const Duration(seconds: 1),
          () => FeatureDiscovery.discoverFeatures(context, ids));

      _settingsManager.setBool(PreferencesFlag.discoveryGradeDetails, true);
    }
  }
}
