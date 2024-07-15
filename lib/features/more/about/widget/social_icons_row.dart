// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/utils/utils.dart';

class SocialIconsRow extends StatelessWidget {
  const SocialIconsRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.earthAmericas,
              color: Colors.white,
            ),
            onPressed: () =>
                Utils.launchURL(Urls.clubWebsite, AppIntl.of(context)!),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.github,
              color: Colors.white,
            ),
            onPressed: () =>
                Utils.launchURL(Urls.clubGithub, AppIntl.of(context)!),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.facebook,
              color: Colors.white,
            ),
            onPressed: () =>
                Utils.launchURL(Urls.clubFacebook, AppIntl.of(context)!),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.twitter,
              color: Colors.white,
            ),
            onPressed: () =>
                Utils.launchURL(Urls.clubTwitter, AppIntl.of(context)!),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.youtube,
              color: Colors.white,
            ),
            onPressed: () =>
                Utils.launchURL(Urls.clubYoutube, AppIntl.of(context)!),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.discord,
              color: Colors.white,
            ),
            onPressed: () =>
                Utils.launchURL(Urls.clubDiscord, AppIntl.of(context)!),
          ),
        ],
      ),
    );
  }
}
