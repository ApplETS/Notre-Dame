// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODELS
import 'package:notredame/core/models/discovery.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

List<Discovery> discoveryComponents(BuildContext context) => [
      Discovery(
        path: RouterPaths.dashboard,
        featureId: 'navbar_dashboard_page_id',
        title: AppIntl.of(context).discovery_navbar_dashboard_page_title,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Text(
                    AppIntl.of(context).discovery_navbar_dashboard_page_details,
                    textAlign: TextAlign.justify),
                const Text('\n'),
                if (AppIntl.of(context).localeName == "fr")
                  Image.asset(
                      'assets/animations/discovery/fr/dashboard_swipe.gif')
                else
                  Image.asset(
                      'assets/animations/discovery/en/dashboard_swipe.gif'),
                const Text('\n'),
                Text(
                    AppIntl.of(context)
                        .discovery_navbar_dashboard_page_details_restore,
                    textAlign: TextAlign.justify),
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
        ),
      ),
      Discovery(
        path: RouterPaths.schedule,
        featureId: 'navbar_schedule_page_id',
        title: AppIntl.of(context).discovery_navbar_schedule_page_title,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Text(AppIntl.of(context).discovery_navbar_schedule_page_details,
                    textAlign: TextAlign.justify),
                const Text('\n'),
                Text(
                    AppIntl.of(context)
                        .discovery_navbar_schedule_page_details_format,
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
        ),
      ),
      Discovery(
        path: RouterPaths.student,
        featureId: 'navbar_students_page_id',
        title: AppIntl.of(context).discovery_navbar_student_page_title,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Text(AppIntl.of(context).discovery_navbar_student_page_details,
                    textAlign: TextAlign.justify),
                const Text('\n'),
                Text(
                    AppIntl.of(context)
                        .discovery_navbar_student_grade_page_details,
                    textAlign: TextAlign.justify),
                const Text('\n'),
                Text(
                    AppIntl.of(context)
                        .discovery_navbar_student_profile_page_details,
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
        ),
      ),
      Discovery(
        path: RouterPaths.ets,
        featureId: 'navbar_ets_page_id',
        title: AppIntl.of(context).discovery_navbar_ets_page_title,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Text(AppIntl.of(context).discovery_navbar_ets_page_details,
                    textAlign: TextAlign.justify),
                const Text('\n'),
                if (AppIntl.of(context).localeName == "fr")
                  Image.asset('assets/animations/discovery/fr/ets_link.gif')
                else
                  Image.asset('assets/animations/discovery/en/ets_link.gif'),
              ],
            ),
          ),
        ),
      ),
      Discovery(
        path: RouterPaths.more,
        featureId: 'navbar_more_page_id',
        title: AppIntl.of(context).discovery_navbar_more_page_title,
        details: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Text(AppIntl.of(context).discovery_navbar_more_page_details,
                    textAlign: TextAlign.justify),
                const Text('\n'),
                if (AppIntl.of(context).localeName == "fr")
                  Image.asset('assets/animations/discovery/fr/more.jpg')
                else
                  Image.asset('assets/animations/discovery/en/more.jpg'),
              ],
            ),
          ),
        ),
      ),
    ];

Discovery getDiscoveryByPath(BuildContext context, String path) {
  return discoveryComponents(context)
      .firstWhere((element) => element.path == path);
}
