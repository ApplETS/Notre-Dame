// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/router_paths.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:notredame/core/models/discovery.dart';
import 'package:notredame/locator.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';

List<Discovery> discoveryComponents(BuildContext context) {
  return [
    Discovery(
      path: RouterPaths.dashboard,
      featureId: 'navbar_dashboard_page_id',
      title: "",
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          children: [
            _buildHeader(
                AppIntl.of(context).discovery_navbar_dashboard_title, context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Text(AppIntl.of(context).discovery_navbar_dashboard_details),
                  const Text('\n'),
                  if (AppIntl.of(context).localeName == "fr")
                    Image.asset(
                        'assets/animations/discovery/fr/dashboard_swipe.gif')
                  else
                    Image.asset(
                        'assets/animations/discovery/en/dashboard_swipe.gif'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: null,
      featureId: 'page_dashboard_restore_id',
      title: AppIntl.of(context).dashboard_restore_all_cards_title,
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildSkipDiscoveryButton(context),
                  Text(
                    AppIntl.of(context).discovery_page_dashboard_restore,
                  ),
                  const Text('\n'),
                  if (AppIntl.of(context).localeName == "fr")
                    Image.asset(
                        'assets/animations/discovery/fr/dashboard_restore.gif')
                  else
                    Image.asset(
                        'assets/animations/discovery/en/dashboard_restore.gif'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: RouterPaths.schedule,
      featureId: 'navbar_schedule_page_id',
      title: "",
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          children: [
            _buildHeader(
                AppIntl.of(context).discovery_navbar_schedule_title, context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Text(AppIntl.of(context).discovery_navbar_schedule_details,
                      textAlign: TextAlign.justify),
                  const Text('\n'),
                  if (AppIntl.of(context).localeName == "fr")
                    Image.asset(
                        'assets/animations/discovery/fr/schedule_calendar.png')
                  else
                    Image.asset(
                        'assets/animations/discovery/en/schedule_calendar.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: RouterPaths.student,
      featureId: 'navbar_students_page_id',
      title: "",
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          children: [
            _buildHeader(
                AppIntl.of(context).discovery_navbar_student_title, context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Text(AppIntl.of(context).discovery_navbar_student_details,
                      textAlign: TextAlign.justify),
                  const Text('\n'),
                  if (AppIntl.of(context).localeName == "fr")
                    Image.asset(
                        'assets/animations/discovery/fr/grade_details.gif')
                  else
                    Image.asset(
                        'assets/animations/discovery/en/grade_details.gif'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: RouterPaths.ets,
      featureId: 'navbar_ets_page_id',
      title: "",
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          children: [
            _buildHeader(
                AppIntl.of(context).discovery_navbar_ets_title, context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Text(AppIntl.of(context).discovery_navbar_ets_details,
                      textAlign: TextAlign.justify),
                  const Text('\n'),
                  if (AppIntl.of(context).localeName == "fr")
                    Image.asset('assets/animations/discovery/fr/ets_link.gif')
                  else
                    Image.asset('assets/animations/discovery/en/ets_link.gif'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: RouterPaths.more,
      featureId: 'navbar_more_page_id',
      title: "",
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          children: [
            _buildHeader(
                AppIntl.of(context).discovery_navbar_more_title, context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Text(AppIntl.of(context).discovery_navbar_more_details,
                      textAlign: TextAlign.justify),
                  const Text('\n'),
                  if (AppIntl.of(context).localeName == "fr")
                    Image.asset('assets/animations/discovery/fr/more.jpg')
                  else
                    Image.asset('assets/animations/discovery/en/more.jpg'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: null,
      featureId: 'page_schedule_settings_id',
      title: AppIntl.of(context).schedule_settings_title,
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildSkipDiscoveryButton(context),
                  Text(AppIntl.of(context).discovery_navbar_schedule_details,
                      textAlign: TextAlign.justify),
                  const Text('\n'),
                  if (AppIntl.of(context).localeName == "fr")
                    Image.asset(
                        'assets/animations/discovery/fr/schedule_settings.gif')
                  else
                    Image.asset(
                        'assets/animations/discovery/en/schedule_settings.gif'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: null,
      featureId: 'page_students_grade_button_id',
      title: AppIntl.of(context).grades_title,
      details: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.25),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildSkipDiscoveryButton(context),
                  Text(
                      AppIntl.of(context).discovery_page_student_grades_session,
                      textAlign: TextAlign.justify),
                  const Text('\n'),
                  Text(
                      AppIntl.of(context)
                          .discovery_page_student_grades_grade_button,
                      textAlign: TextAlign.justify),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: null,
      featureId: 'page_student_page_profile',
      title: AppIntl.of(context).profile_title,
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildSkipDiscoveryButton(context),
                  Text(AppIntl.of(context).discovery_page_student_profile,
                      textAlign: TextAlign.justify),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: null,
      featureId: 'page_more_bug_report_id',
      title: AppIntl.of(context).more_report_bug,
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSkipDiscoveryButton(context),
                  Text(AppIntl.of(context).discovery_page_more_report_bug,
                      textAlign: TextAlign.justify),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: null,
      featureId: 'page_more_contributors_id',
      title: AppIntl.of(context).more_contributors,
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildSkipDiscoveryButton(context),
                  Text(AppIntl.of(context).discovery_page_more_contributors,
                      textAlign: TextAlign.justify),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: null,
      featureId: 'page_more_settings_id',
      title: AppIntl.of(context).more_settings,
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildSkipDiscoveryButton(context),
                  Text(AppIntl.of(context).discovery_page_more_settings,
                      textAlign: TextAlign.justify),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Discovery(
      path: null,
      featureId: 'page_more_thank_you_id',
      title: AppIntl.of(context).title_ets_mobile,
      details: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildSkipDiscoveryButton(context),
                  Text(AppIntl.of(context).discovery_page_thankyou_message,
                      textAlign: TextAlign.justify),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ];
}

Padding _buildHeader(String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.white)),
        _buildSkipDiscoveryButton(context)
      ],
    ),
  );
}

Align _buildSkipDiscoveryButton(BuildContext context) {
  return Align(
    alignment: Alignment.topRight,
    child: TextButton(
      onPressed: () => FeatureDiscovery.dismissAll(context),
      child: Text(AppIntl.of(context).skip_discovery,
          style: const TextStyle(color: AppTheme.etsLightRed)),
    ),
  );
}

void dismissDiscovery(BuildContext context) {
  final SettingsManager _settingsManager = locator<SettingsManager>();

  FeatureDiscovery.dismissAll(context);
  _settingsManager.setString(PreferencesFlag.discoveryDashboard, 'true');
  _settingsManager.setString(PreferencesFlag.discoverySchedule, 'true');
  _settingsManager.setString(PreferencesFlag.discoveryStudentGrade, 'true');
  _settingsManager.setString(PreferencesFlag.discoveryStudentProfile, 'true');
  _settingsManager.setString(PreferencesFlag.discoveryMore, 'true');
}

Discovery getDiscoveryByPath(BuildContext context, String path) {
  return discoveryComponents(context)
      .firstWhere((element) => element.path == path);
}

Discovery getDiscoveryByFeatureId(BuildContext context, String featureId) {
  return discoveryComponents(context)
      .firstWhere((element) => element.featureId == featureId);
}
