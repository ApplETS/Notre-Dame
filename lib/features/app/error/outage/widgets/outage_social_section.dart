// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';

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
                icon: const FaIcon(
                  FontAwesomeIcons.earthAmericas,
                  color: Colors.white,
                ),
                onPressed: () =>
                    _launchUrlService.launchInBrowser(Urls.clubWebsite)),
                IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.github,
                  color: Colors.white,
                ),
                onPressed: () =>
                    _launchUrlService.launchInBrowser(Urls.clubGithub)),
            IconButton(
                icon: const FaIcon(
                  Icons.mail_outline,
                  color: Colors.white,
                ),
                onPressed: () =>
                    _launchUrlService.writeEmail(Urls.clubEmail, "")),
            IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.discord,
                  color: Colors.white,
                ),
                onPressed: () =>
                    _launchUrlService.launchInBrowser(Urls.clubDiscord))
          ],
        ),
      ],
    );
  }
}
