// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODELS
import 'package:notredame/core/models/discovery.dart';

// OTHER
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
                Image.asset('assets/animations/dashboard_swipe_fr.gif'),
                const Text('\n'),
                Text(
                    AppIntl.of(context)
                        .discovery_navbar_dashboard_page_details_restore,
                    textAlign: TextAlign.justify),
                const Text('\n'),
                Image.asset('assets/animations/dashboard_restore_fr.gif'),
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
                Image.asset('assets/animations/schedule_settings_fr.gif'),
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
                Image.asset('assets/animations/ets_link_fr.gif'),
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
                Image.asset('assets/animations/more_fr.jpg'),
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
