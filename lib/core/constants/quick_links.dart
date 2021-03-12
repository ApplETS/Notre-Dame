import 'package:notredame/core/models/quick_link.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<QuickLink> quickLinks(AppIntl intl) => [
      QuickLink(
          name: intl.ets_security_title,
          image: 'assets/images/ic_security_red.png',
          link: 'security'),
      QuickLink(
          name: intl.ets_monets_title,
          image: 'assets/images/ic_monets_sans_nom_red.png',
          link: 'https://portail.etsmtl.ca'),
      QuickLink(
          name: intl.ets_bibliotech_title,
          image: 'assets/images/ic_book_red.png',
          link: 'https://www.etsmtl.ca/Bibliotheque/Accueil'),
      QuickLink(
          name: intl.ets_news_title,
          image: 'assets/images/ic_newspaper_red.png',
          link: 'https://www.etsmtl.ca/nouvelles'),
      QuickLink(
          name: intl.ets_directory_title,
          image: 'assets/images/ic_import_contacts_red.png',
          link: 'https://www.etsmtl.ca/bottin'),
      QuickLink(
          name: intl.ets_moodle_title,
          image: 'assets/images/ic_moodle_red.png',
          link: 'https://ena.etsmtl.ca/'),
      QuickLink(
          name: intl.ets_heuristique_title,
          image: 'assets/images/ic_heuristique_red.png',
          link: 'http://lheuristique.ca'),
      QuickLink(
          name: intl.ets_schedule_generator,
          image: 'assets/images/ic_schedule_generator_red.png',
          link: 'http://rubik.clubnaova.ca/'),
    ];
