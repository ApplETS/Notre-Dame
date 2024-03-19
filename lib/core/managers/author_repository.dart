// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/core/models/author.dart';
import 'package:notredame/core/models/socialLink.dart';
import 'package:notredame/locator.dart';

/// Repository to access authors
class AuthorRepository {
  static const String tag = "AuthorRepository";

  final Logger _logger = locator<Logger>();

  final Author _author = Author(
      id: "1",
      organisation: "Capra",
      email: "capra@ens.etsmtl.ca",
      description:
          "Le club Capra fait la conception et la fabrication d’un robot de recherche et de sauvetage en milieux accidentés et participe à la compétition RoboCupRescue.",
      activity: "Club scientifique",
      website: "capra.com",
      image: "https://cdn-icons-png.flaticon.com/512/147/147142.png",
      socialLinks: [
        SocialLink(id: 1, name: "discord", link: "facebook.com/capra"),
        SocialLink(id: 2, name: "linkedin", link: "facebook.com/capra"),
        SocialLink(id: 3, name: "email", link: "facebook.com/capra"),
        SocialLink(id: 4, name: "x", link: "facebook.com/capra"),
        SocialLink(id: 5, name: "tiktok", link: "facebook.com/capra"),
        SocialLink(id: 6, name: "facebook", link: "facebook.com/capra"),
        SocialLink(id: 7, name: "instagram", link: "facebook.com/capra"),
        SocialLink(id: 8, name: "reddit", link: "facebook.com/capra"),
      ]);

  Author get author => _author;

  // TODO : Fetch author from the API
  Author fetchAuthorFromAPI(String authorId) {
    _logger.d("$tag - fetchAuthorFromAPI: fetched author.");

    return author;
  }
}
