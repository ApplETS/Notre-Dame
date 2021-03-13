import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/models/discovery.dart';

List<Discovery> discoveryIds(AppIntl intl) => [
      Discovery(
          id: 'navbar_dashboard_page_id',
          title: intl.discovery_navbar_dashboard_page_title,
          detail: intl.discovery_navbar_dashboard_page_details),
      /*Discovery(
          id: 'navbar_schedule_page_id',
          title: intl.discovery_navbar_schedule_page_title,
          detail: intl.discovery_navbar_schedule_page_details),
      Discovery(
          id: 'navbar_students_page_id',
          title: intl.discovery_navbar_student_page_title,
          detail: intl.discovery_navbar_student_page_details),
      Discovery(
          id: 'navbar_ets_page_id',
          title: intl.discovery_navbar_ets_page_title,
          detail: intl.discovery_navbar_ets_page_details),
      Discovery(
          id: 'navbar_more_page_id',
          title: intl.discovery_navbar_more_page_title,
          detail: intl.discovery_navbar_more_page_details),*/
    ];
