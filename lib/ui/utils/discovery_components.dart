// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/core/constants/discovery_ids.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/discovery.dart';
import 'package:notredame/core/models/group_discovery.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

List<GroupDiscovery> discoveryComponents(BuildContext context) {
  return [
    GroupDiscovery(name: DiscoveryGroupIds.bottomBar, discoveries: [
      Discovery(
        path: RouterPaths.dashboard,
        featureId: DiscoveryIds.bottomBarDashboard,
        title: "",
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Column(
            children: [
              _buildHeader(AppIntl.of(context).discovery_navbar_dashboard_title,
                  context),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Text(
                        AppIntl.of(context).discovery_navbar_dashboard_details),
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
        featureId: DiscoveryIds.bottomBarDashboardRestore,
        title: AppIntl.of(context).dashboard_restore_all_cards_title,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4),
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
        featureId: DiscoveryIds.bottomBarSchedule,
        title: "",
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
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
        featureId: DiscoveryIds.bottomBarStudent,
        title: "",
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
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
        featureId: DiscoveryIds.bottomBarETS,
        title: "",
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
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
                      Image.asset(
                          'assets/animations/discovery/en/ets_link.gif'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Discovery(
        path: RouterPaths.more,
        featureId: DiscoveryIds.bottomBarMore,
        title: "",
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
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
    ]),
    GroupDiscovery(name: DiscoveryGroupIds.pageSchedule, discoveries: [
      Discovery(
        path: null,
        featureId: DiscoveryIds.detailsScheduleSettings,
        title: AppIntl.of(context).schedule_settings_title,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
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
    ]),
    GroupDiscovery(name: DiscoveryGroupIds.pageStudent, discoveries: [
      Discovery(
        path: null,
        featureId: DiscoveryIds.detailsStudentGradeButton,
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
                        AppIntl.of(context)
                            .discovery_page_student_grades_session,
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
        featureId: DiscoveryIds.detailsStudentProfile,
        title: AppIntl.of(context).profile_title,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2),
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
    ]),
    GroupDiscovery(name: DiscoveryGroupIds.pageGradeDetails, discoveries: [
      Discovery(
        path: null,
        featureId: DiscoveryIds.detailsGradeDetailsEvaluations,
        title: "",
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    _buildSkipDiscoveryButton(context),
                    Text(AppIntl.of(context).discovery_page_grade_details,
                        textAlign: TextAlign.justify),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ]),
    GroupDiscovery(name: DiscoveryGroupIds.pageMore, discoveries: [
      Discovery(
        path: null,
        featureId: DiscoveryIds.detailsMoreBugReport,
        title: AppIntl.of(context).more_report_bug,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2),
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
        featureId: DiscoveryIds.detailsMoreContributors,
        title: AppIntl.of(context).more_contributors,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2),
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
        featureId: DiscoveryIds.detailsMoreFaq,
        title: AppIntl.of(context).need_help,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    _buildSkipDiscoveryButton(context),
                    Text(AppIntl.of(context).discovery_page_faq,
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
        featureId: DiscoveryIds.detailsMoreSettings,
        title: AppIntl.of(context).more_settings,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2),
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
        featureId: DiscoveryIds.detailsMoreThankYou,
        title: AppIntl.of(context).title_ets_mobile,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2),
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
    ]),
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
      onPressed: () => dismissDiscovery(context),
      child: Text(AppIntl.of(context).skip_discovery,
          style: const TextStyle(color: AppTheme.etsLightRed)),
    ),
  );
}

void dismissDiscovery(BuildContext context) {
  final SettingsManager settingsManager = locator<SettingsManager>();

  FeatureDiscovery.dismissAll(context);

  settingsManager.setBool(PreferencesFlag.discoveryDashboard, true);
  settingsManager.setBool(PreferencesFlag.discoverySchedule, true);
  settingsManager.setBool(PreferencesFlag.discoveryStudentGrade, true);
  settingsManager.setBool(PreferencesFlag.discoveryGradeDetails, true);
  settingsManager.setBool(PreferencesFlag.discoveryStudentProfile, true);
  settingsManager.setBool(PreferencesFlag.discoveryMore, true);
}

Discovery getDiscoveryByPath(BuildContext context, String group, String path) {
  return discoveryComponents(context)
      .firstWhere((element) => element.name == group)
      .discoveries
      .firstWhere((element) => element.path == path);
}

Discovery getDiscoveryByFeatureId(
    BuildContext context, String group, String featureId) {
  return discoveryComponents(context)
      .firstWhere((element) => element.name == group)
      .discoveries
      .firstWhere((element) => element.featureId == featureId);
}

List<Discovery> findDiscoveriesByGroupName(
    BuildContext context, String groupName) {
  return discoveryComponents(context)
      .firstWhere((element) => element.name == groupName)
      .discoveries;
}
