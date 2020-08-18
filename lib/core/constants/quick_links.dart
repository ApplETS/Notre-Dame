import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';
import 'package:notredame/generated/l10n.dart';

final List<QuickLinks> quickLinks = [
  QuickLinks(
      name: AppIntl.current.ets_security_title,
      image: 'assets/ic_security_red.png',
      link: 'security'),
  QuickLinks(
      name: AppIntl.current.ets_monets_title,
      image: 'assets/ic_monets_sans_nom_red.png',
      link: 'https://portail.etsmtl.ca'),
  QuickLinks(
      name: AppIntl.current.ets_bibliotech_title,
      image: 'assets/ic_book_red.png',
      link: 'https://www.etsmtl.ca/Bibliotheque/Accueil'),
  QuickLinks(
      name: AppIntl.current.ets_news_title,
      image: 'assets/ic_newspaper_red.png',
      link: 'https://www.etsmtl.ca/nouvelles'),
  QuickLinks(
      name: AppIntl.current.ets_directory_title,
      image: 'assets/ic_import_contacts_red.png',
      link: 'https://www.etsmtl.ca/bottin'),
  QuickLinks(
      name: AppIntl.current.ets_moodle_title,
      image: 'assets/ic_moodle_red.png',
      link: 'https://ena.etsmtl.ca/'),
  QuickLinks(
      name: AppIntl.current.ets_heuristique_title,
      image: 'assets/ic_heuristique_red.png',
      link: 'http://lheuristique.ca')
];
