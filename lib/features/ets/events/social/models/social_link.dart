// Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/models/quick_link.dart';

class SocialLink extends QuickLink {
  SocialLink({
    required super.id,
    required super.name,
    required super.link,
  }) : super(
            image: SvgPicture.asset(
          "assets/images/${name.toLowerCase()}_logo.svg",
          height: 55,
          width: 55,
        ));
}
