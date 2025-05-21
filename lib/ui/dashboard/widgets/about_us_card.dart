// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/domain/constants/urls.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';

class AboutUsCard extends StatelessWidget {
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  final VoidCallback _onDismissed;

  AboutUsCard({required super.key, required VoidCallback onDismissed}) : _onDismissed = onDismissed;

  @override
  Widget build(BuildContext context) => DismissibleCard(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) => _onDismissed(),
        cardColor: AppPalette.appletsPurple,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child:
                    Text(AppIntl.of(context)!.card_applets_title, style: Theme.of(context).primaryTextTheme.titleLarge),
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
                child:
                    Text(AppIntl.of(context)!.card_applets_text, style: Theme.of(context).primaryTextTheme.bodyMedium),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Wrap(spacing: 15.0, children: [
                    IconButton(
                      tooltip: AppIntl.of(context)!.facebook_open,
                      onPressed: () {
                        _launchUrlService.launchInBrowser(Urls.clubFacebook);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.facebook,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: AppIntl.of(context)!.instagram_open,
                      onPressed: () {
                        _launchUrlService.launchInBrowser(Urls.clubInstagram);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.instagram,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: AppIntl.of(context)!.github_open,
                      onPressed: () {
                        _launchUrlService.launchInBrowser(Urls.clubGithub);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.github,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: AppIntl.of(context)!.email_send,
                      onPressed: () {
                        _launchUrlService.writeEmail(Urls.clubEmail, "");
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.envelope,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: AppIntl.of(context)!.discord_join,
                      onPressed: () {
                        _launchUrlService.launchInBrowser(Urls.clubDiscord);
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
