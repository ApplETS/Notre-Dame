// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

List<QuickLink> quickLinks(AppIntl intl) => [
  QuickLink(
    id: 1,
    name: intl.ets_security_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.shieldHalved, color: AppPalette.etsLightRed)),
    link: 'security',
  ),
  QuickLink(
    id: 2,
    name: intl.ets_monets_title,
    image: Image.asset('assets/images/ic_monets_sans_nom_red.png', color: AppPalette.etsLightRed),
    link: 'https://portail.etsmtl.ca/home',
  ),
  QuickLink(
    id: 3,
    name: intl.ets_bibliotech_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.book, color: AppPalette.etsLightRed)),
    link: 'https://www.etsmtl.ca/Bibliotheque/Accueil',
  ),
  QuickLink(
    id: 4,
    name: intl.ets_news_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.newspaper, color: AppPalette.etsLightRed)),
    link: 'https://www.etsmtl.ca/nouvelles',
  ),
  QuickLink(
    id: 5,
    name: intl.ets_directory_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.addressBook, color: AppPalette.etsLightRed)),
    link: 'https://www.etsmtl.ca/bottin',
  ),
  QuickLink(
    id: 6,
    name: intl.ets_moodle_title,
    image: Image.asset('assets/images/ic_moodle_red.png', color: AppPalette.etsLightRed),
    link: 'https://ena.etsmtl.ca/',
  ),
  QuickLink(
    id: 7,
    name: intl.ets_schedule_generator,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.calendar, color: AppPalette.etsLightRed)),
    link: 'https://horairets.emmanuelcoulombe.dev/',
  ),
  QuickLink(
    id: 8,
    name: intl.ets_gus,
    image: SvgPicture.asset(
      'assets/images/ic_gus_red.svg',
      colorFilter: const ColorFilter.mode(AppPalette.etsLightRed, BlendMode.srcIn),
    ),
    link: 'https://gus.etsmtl.ca/c2atom/mobile/login',
  ),
  QuickLink(
    id: 9,
    name: intl.ets_papercut_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.print, color: AppPalette.etsLightRed)),
    link: 'https://cls.etsmtl.ca/user',
  ),
  QuickLink(
    id: 10,
    name: intl.ets_aeets_title,
    image: Image.asset('assets/images/ic_aeets_red.png', color: AppPalette.etsLightRed),
    link: 'https://www.aeets.com/',
  ),
  QuickLink(
    id: 11,
    name: intl.ets_100genies_title,
    image: Image.asset('assets/images/ic_100genies_red.png', color: AppPalette.etsLightRed),
    link: 'https://www.pub100genies.ca/',
  ),
  QuickLink(
    id: 12,
    name: intl.ets_stages_et_emplois_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.userTie, color: AppPalette.etsLightRed)),
    link: 'https://see.etsmtl.ca/Accueil',
  ),
  QuickLink(
    id: 13,
    name: intl.ets_eportfolio_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.addressCard, color: AppPalette.etsLightRed)),
    link: 'https://eportfolio.etsmtl.ca/Etudiant',
  ),
  QuickLink(
    id: 14,
    name: intl.ets_ebourses_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.sackDollar, color: AppPalette.etsLightRed)),
    link: 'https://ebourses.etsmtl.ca/',
  ),
  QuickLink(
    id: 15,
    name: intl.ets_appui_reussite_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.solidHandshake, color: AppPalette.etsLightRed)),
    link: 'https://www.etsmtl.ca/experience-etudiante/appui-a-la-reussite',
  ),
  QuickLink(
    id: 16,
    name: intl.ets_nimbus_title,
    image: Image.asset('assets/images/nimbus_logo.png', color: AppPalette.etsLightRed),
    link: 'https://www.etsmtl.ca/experience-etudiante/appui-a-la-reussite/tutorat-par-les-pairs-nimbus',
  ),
  QuickLink(
    id: 17,
    name: intl.ets_centre_sportif_title,
    image: Image.asset('assets/images/centre_sportif_logo.png', color: AppPalette.etsLightRed),
    link: 'https://www.etsmtl.ca/satellite/centre-sportif',
  ),
  QuickLink(
    id: 18,
    name: intl.ets_etudiants_actuels_title,
    image: const FittedBox(child: FaIcon(FontAwesomeIcons.userGraduate, color: AppPalette.etsLightRed)),
    link: 'https://www.etsmtl.ca/etudiants-actuels',
  ),
  QuickLink(
    id: 19,
    name: intl.ets_cafe_sans_filtre_title,
    image: Image.asset('assets/images/cafe_sans_filtre_logo.png', color: AppPalette.etsLightRed),
    link: 'https://cafesansfiltre.com/',
  ),
];
