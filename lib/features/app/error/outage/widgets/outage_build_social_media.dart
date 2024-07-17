// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/error/outage/outage_viewmodel.dart';
import 'package:notredame/utils/utils.dart';

Widget outageSocialSection(OutageViewModel model, BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      SizedBox(
        height: model.getContactTextPlacement(context),
        child: Text(
          AppIntl.of(context)!.service_outage_contact,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
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
