// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/constants/router_paths.dart';

// MODELS
import 'package:notredame/core/models/discovery.dart';

List<Discovery> discoveryComponents(BuildContext context) => [
      Discovery(
        path: RouterPaths.dashboard,
        featureId: 'navbar_dashboard_page_id',
        title: AppIntl.of(context).discovery_navbar_dashboard_page_title,
        details: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView(
            children: <Widget>[
              Text(AppIntl.of(context).discovery_navbar_dashboard_page_details,
                  textAlign: TextAlign.justify),
              const Text('\n'),
              Image.asset('assets/animations/dashboard_swipe_left.gif'),
              const Text('\n'),
              Text(AppIntl.of(context).discovery_navbar_dashboard_page_details2,
                  textAlign: TextAlign.justify),
              const Text('\n'),
              Image.asset('assets/animations/dashboard_restore.gif'),
            ],
          ),
        ),
      ),
      Discovery(
        path: RouterPaths.schedule,
        featureId: 'navbar_schedule_page_id',
        title: AppIntl.of(context).discovery_navbar_schedule_page_title,
        details: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppIntl.of(context).discovery_navbar_schedule_page_details,
                textAlign: TextAlign.justify),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  const TextSpan(text: '\n'),
                  const WidgetSpan(
                      child: Icon(Icons.settings, size: 16, color: Colors.white)),
                  TextSpan(text:' ${AppIntl.of(context).discovery_navbar_schedule_page_details2}'),
                ],
              ),
            ),
          ],
        ),
      ),
      Discovery(
          path: RouterPaths.student,
          featureId: 'navbar_students_page_id',
          title: AppIntl.of(context).discovery_navbar_student_page_title,
          details: Text(
              AppIntl.of(context).discovery_navbar_student_page_details,
              textAlign: TextAlign.justify)),
      Discovery(
          path: RouterPaths.ets,
          featureId: 'navbar_ets_page_id',
          title: AppIntl.of(context).discovery_navbar_ets_page_title,
          details: Text(AppIntl.of(context).discovery_navbar_ets_page_details,
              textAlign: TextAlign.justify)),
      Discovery(
          path: RouterPaths.more,
          featureId: 'navbar_more_page_id',
          title: AppIntl.of(context).discovery_navbar_more_page_title,
          details: Text(AppIntl.of(context).discovery_navbar_more_page_details,
              textAlign: TextAlign.justify)),
    ];

Discovery getDiscoveryByPath(BuildContext context, String path) {
  return discoveryComponents(context).firstWhere((element) => element.path == path);
}
