// Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:notredame/core/models/quick_link.dart';

class SocialLink extends QuickLink {
  SocialLink({
    required super.id,
    required super.name,
    required super.link,
  }) : super(
            image: SvgPicture.asset(
          "assets/images/${name}_logo.svg",
          height: 55,
          width: 55,
        )) {
    ;
  }
}
