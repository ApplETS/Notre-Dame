// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICE

// OTHERS

class GradesDetailsViewModel extends BaseViewModel {
  /// Localization class of the application.
  final AppIntl _appIntl;

  GradesDetailsViewModel({@required AppIntl intl}) : _appIntl = intl;

  /// Reload the grades from Signets and rebuild the view.
  Future<bool> refresh() async {
    try {
      /*await _courseRepository.getCourses();
      _buildCoursesBySession(_courseRepository.courses);*/
      notifyListeners();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}
