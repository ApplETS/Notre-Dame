// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/ui/utils/app_theme.dart';

List<QuickLink> quickLinks(AppIntl intl) => [
      QuickLink(
          id: 1,
          name: intl.ets_security_title,
          image: const FittedBox(
            child: FaIcon(
              FontAwesomeIcons.shieldHalved,
              color: AppTheme.etsLightRed,
            ),
          ),
          link: 'security'),
      QuickLink(
          id: 2,
          name: intl.ets_monets_title,
          image: Image.asset(
            'assets/images/ic_monets_sans_nom_red.png',
            color: AppTheme.etsLightRed,
          ),
          link: 'https://portail.etsmtl.ca/home'),
      QuickLink(
          id: 3,
          name: intl.ets_bibliotech_title,
          image: const FittedBox(
            child: FaIcon(
              FontAwesomeIcons.book,
              color: AppTheme.etsLightRed,
            ),
          ),
          link: 'https://www.etsmtl.ca/Bibliotheque/Accueil'),
      QuickLink(
          id: 4,
          name: intl.ets_news_title,
          image: const FittedBox(
            child: FaIcon(
              FontAwesomeIcons.newspaper,
              color: AppTheme.etsLightRed,
            ),
          ),
          link: 'https://www.etsmtl.ca/nouvelles'),
      QuickLink(
          id: 5,
          name: intl.ets_directory_title,
          image: const FittedBox(
            child: FaIcon(
              FontAwesomeIcons.addressBook,
              color: AppTheme.etsLightRed,
            ),
          ),
          link: 'https://www.etsmtl.ca/bottin'),
      QuickLink(
          id: 6,
          name: intl.ets_moodle_title,
          image: Image.asset(
            'assets/images/ic_moodle_red.png',
            color: AppTheme.etsLightRed,
          ),
          link: 'https://ena.etsmtl.ca/'),
      QuickLink(
          id: 7,
          name: intl.ets_schedule_generator,
          image: const FittedBox(
            child: FaIcon(
              FontAwesomeIcons.calendar,
              color: AppTheme.etsLightRed,
            ),
          ),
          link: 'https://horairets.emmanuelcoulombe.dev/'),
      QuickLink(
          id: 8,
          name: intl.ets_gus,
          image: SvgPicture.asset('assets/images/ic_gus_red.svg',
              colorFilter: const ColorFilter.mode(
                  AppTheme.etsLightRed, BlendMode.srcIn)),
          link: 'https://gus.etsmtl.ca/c2atom/mobile/login'),
      QuickLink(
          id: 9,
          name: intl.ets_papercut_title,
          image: const FittedBox(
            child: FaIcon(
              FontAwesomeIcons.print,
              color: AppTheme.etsLightRed,
            ),
          ),
          link: 'https://cls.etsmtl.ca/user'),
    ];
