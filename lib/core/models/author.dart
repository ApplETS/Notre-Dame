// Project imports:
import 'package:notredame/core/models/socialLink.dart';

class Author {
  final int id;
  final String organisation;
  final String email;
  final String description;
  final String activity;
  final String website;
  final String image;
  final List<SocialLink> socialLinks;

  Author(
      {required this.id,
      required this.organisation,
      required this.email,
      required this.description,
      required this.activity,
      required this.website,
      required this.image,
      required this.socialLinks});
}
