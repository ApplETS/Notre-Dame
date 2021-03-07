import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/generated/l10n.dart';

final List<QuickLink> quickLinks = [
  QuickLink(
      name: AppIntl.current.ets_security_title,
      image: 'assets/images/ic_security_red.png',
      link: 'security'),
  QuickLink(
      name: AppIntl.current.ets_monets_title,
      image: 'assets/images/ic_monets_sans_nom_red.png',
      link: 'https://portail.etsmtl.ca'),
  QuickLink(
      name: AppIntl.current.ets_bibliotech_title,
      image: 'assets/images/ic_book_red.png',
      link: 'https://www.etsmtl.ca/Bibliotheque/Accueil'),
  QuickLink(
      name: AppIntl.current.ets_news_title,
      image: 'assets/images/ic_newspaper_red.png',
      link: 'https://www.etsmtl.ca/nouvelles'),
  QuickLink(
      name: AppIntl.current.ets_directory_title,
      image: 'assets/images/ic_import_contacts_red.png',
      link: 'https://www.etsmtl.ca/bottin'),
  QuickLink(
      name: AppIntl.current.ets_moodle_title,
      image: 'assets/images/ic_moodle_red.png',
      link: 'https://ena.etsmtl.ca/'),
  QuickLink(
      name: AppIntl.current.ets_heuristique_title,
      image: 'assets/images/ic_heuristique_red.png',
      link: 'http://lheuristique.ca'),
  QuickLink(
      name: AppIntl.current.ets_schedule_generator,
      image: 'assets/images/ic_moodle_red.png',
      link: 'http://rubik.clubnaova.ca/'),
];
