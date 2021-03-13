// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

// OTHER
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/preferences_flags.dart';

class DashboardViewModel extends BaseViewModel {
  /// Localization class of the application.
  final AppIntl _appIntl;

  DashboardViewModel({@required AppIntl intl}) : _appIntl = intl;
}
