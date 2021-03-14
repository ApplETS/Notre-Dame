import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/models/discovery.dart';

List<Discovery> discoveryIds(AppIntl intl) => [
      Discovery(
          path: RouterPaths.dashboard,
          featureId: 'navbar_dashboard_page_id',
          title: intl.discovery_navbar_dashboard_page_title,
          detail: intl.discovery_navbar_dashboard_page_details),
      Discovery(
          path: RouterPaths.schedule,
          featureId: 'navbar_schedule_page_id',
          title: intl.discovery_navbar_schedule_page_title,
          detail: intl.discovery_navbar_schedule_page_details),
      Discovery(
          path: RouterPaths.student,
          featureId: 'navbar_students_page_id',
          title: intl.discovery_navbar_student_page_title,
          detail: intl.discovery_navbar_student_page_details),
      Discovery(
          path: RouterPaths.ets,
          featureId: 'navbar_ets_page_id',
          title: intl.discovery_navbar_ets_page_title,
          detail: intl.discovery_navbar_ets_page_details),
      Discovery(
          path: RouterPaths.more,
          featureId: 'navbar_more_page_id',
          title: intl.discovery_navbar_more_page_title,
          detail: intl.discovery_navbar_more_page_details),
    ];

Discovery getDiscoveryByPath(AppIntl intl, String path) {
  return discoveryIds(intl).firstWhere((element) => element.path == path);
}
