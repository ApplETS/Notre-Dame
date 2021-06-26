// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';

List<QuickLink> quickLinks(AppIntl intl) => [
      QuickLink(
          name: intl.ets_security_title,
          image: const FaIcon(
            FontAwesomeIcons.shieldAlt,
            color: AppTheme.etsLightRed,
            size: 64,
          ),
          link: 'security'),
      QuickLink(
          name: intl.ets_monets_title,
          image: Image.asset(
            'assets/images/ic_monets_sans_nom_red.png',
            color: AppTheme.etsLightRed,
          ),
          link: 'https://portail.etsmtl.ca'),
      QuickLink(
          name: intl.ets_bibliotech_title,
          image: const FaIcon(
            FontAwesomeIcons.book,
            color: AppTheme.etsLightRed,
            size: 64,
          ),
          link: 'https://www.etsmtl.ca/Bibliotheque/Accueil'),
      QuickLink(
          name: intl.ets_news_title,
          image: const FaIcon(
            FontAwesomeIcons.newspaper,
            color: AppTheme.etsLightRed,
            size: 64,
          ),
          link: 'https://www.etsmtl.ca/nouvelles'),
      QuickLink(
          name: intl.ets_directory_title,
          image: const FaIcon(
            FontAwesomeIcons.addressBook,
            color: AppTheme.etsLightRed,
            size: 64,
          ),
          link: 'https://www.etsmtl.ca/bottin'),
      QuickLink(
          name: intl.ets_moodle_title,
          image: Image.asset(
            'assets/images/ic_moodle_red.png',
            color: AppTheme.etsLightRed,
          ),
          link: 'https://ena.etsmtl.ca/'),
      QuickLink(
          name: intl.ets_heuristique_title,
          image: Image.asset(
            'assets/images/ic_heuristique_red.png',
            color: AppTheme.etsLightRed,
          ),
          link: 'http://lheuristique.ca'),
      QuickLink(
          name: intl.ets_schedule_generator,
          image: const FaIcon(
            FontAwesomeIcons.calendar,
            color: AppTheme.etsLightRed,
            size: 64,
          ),
          link: 'http://rubik.clubnaova.ca/'),
      QuickLink(
          name: intl.ets_gus,
          image: Image.asset('assets/images/ic_gus_red.png'),
          link: 'https://gus.etsmtl.ca/c2atom/mobile/login'),
    ];
