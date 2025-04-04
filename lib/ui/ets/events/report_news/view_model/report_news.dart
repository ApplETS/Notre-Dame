// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/data/models/hello/report_news.dart';

List<ReportNews> getLocalizedReportNewsItems(BuildContext context) {
  return [
    ReportNews(
        title: AppIntl.of(context)!.report_inappropriate_content,
        description: AppIntl.of(context)!.report_inappropriate_content_description,
        category: "1"),
    ReportNews(
        title: AppIntl.of(context)!.report_false_information,
        description: AppIntl.of(context)!.report_false_information_description,
        category: "2"),
    ReportNews(
        title: AppIntl.of(context)!.report_harassment_or_abuse,
        description: AppIntl.of(context)!.report_harassment_or_abuse_description,
        category: "3"),
    ReportNews(
        title: AppIntl.of(context)!.report_outdated_content,
        description: AppIntl.of(context)!.report_outdated_content_description,
        category: "4"),
  ];
}
