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

class OutageSocialSection extends StatelessWidget {
  OutageSocialSection({super.key});
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.earthAmericas,
                  color: AppPalette.grey.white,
                ),
                tooltip: AppIntl.of(context)!.website_club_open,
                onPressed: () => _launchUrlService.launchInBrowser(Urls.clubWebsite)),
            IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.github,
                  color: AppPalette.grey.white,
                ),
                tooltip: AppIntl.of(context)!.github_open,
                onPressed: () => _launchUrlService.launchInBrowser(Urls.clubGithub)),
            IconButton(
                icon: FaIcon(
                  Icons.mail_outline,
                  color: AppPalette.grey.white,
                ),
                tooltip: AppIntl.of(context)!.email_send,
                onPressed: () => _launchUrlService.writeEmail(Urls.clubEmail, "")),
            IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.discord,
                  color: AppPalette.grey.white,
                ),
                tooltip: AppIntl.of(context)!.discord_join,
                onPressed: () => _launchUrlService.launchInBrowser(Urls.clubDiscord))
          ],
        ),
      ],
    );
  }
}
