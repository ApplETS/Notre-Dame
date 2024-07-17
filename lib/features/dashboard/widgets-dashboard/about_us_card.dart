// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

class AboutUsCard extends StatelessWidget {
  final DashboardViewModel model;
  final PreferencesFlag flag;
  final AnalyticsService analyticsService;
  static const String tag = "DashboardView";

  const AboutUsCard({
    super.key,
    required this.model,
    required this.flag,
    required this.analyticsService,
  });

  @override
  Widget build(BuildContext context) {
    return DismissibleCard(
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) {
        model.hideCard(flag);
      },
      cardColor: AppTheme.appletsPurple,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
              child: Text(AppIntl.of(context)!.card_applets_title,
                  style: Theme.of(context).primaryTextTheme.titleLarge),
            )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
              child: Text(AppIntl.of(context)!.card_applets_text,
                  style: Theme.of(context).primaryTextTheme.bodyMedium),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Wrap(spacing: 15.0, children: [
                  IconButton(
                    onPressed: () {
                      analyticsService.logEvent(tag, "Facebook clicked");
                      Utils.launchURL(Urls.clubFacebook, AppIntl.of(context)!);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.facebook,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      analyticsService.logEvent(tag, "Instagram clicked");
                      Utils.launchURL(Urls.clubInstagram, AppIntl.of(context)!);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.instagram,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      analyticsService.logEvent(tag, "Github clicked");
                      Utils.launchURL(Urls.clubGithub, AppIntl.of(context)!);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.github,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      analyticsService.logEvent(tag, "Email clicked");
                      Utils.launchURL(Urls.clubEmail, AppIntl.of(context)!);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.envelope,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      analyticsService.logEvent(tag, "Discord clicked");
                      Utils.launchURL(Urls.clubDiscord, AppIntl.of(context)!);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.discord,
                      color: Colors.white,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
