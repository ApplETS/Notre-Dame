// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/utils/utils.dart';

class OutageSocialSection extends StatelessWidget {
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
                    Utils.launchURL(Urls.clubWebsite, AppIntl.of(context)!)),
            IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.github,
                  color: Colors.white,
                ),
                onPressed: () =>
                    Utils.launchURL(Urls.clubGithub, AppIntl.of(context)!)),
            IconButton(
                icon: const FaIcon(
                  Icons.mail_outline,
                  color: Colors.white,
                ),
                onPressed: () =>
                    Utils.launchURL(Urls.clubEmail, AppIntl.of(context)!)),
            IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.discord,
                  color: Colors.white,
                ),
                onPressed: () =>
                    Utils.launchURL(Urls.clubDiscord, AppIntl.of(context)!)),
          ],
        ),
      ],
    );
  }
}
