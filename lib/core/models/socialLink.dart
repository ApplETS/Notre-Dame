import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notredame/core/models/quick_link.dart';

class SocialLink extends QuickLink {
  SocialLink({
    required int id,
    required String name,
    required String link,
  }) : super(
            id: id,
            image: SvgPicture.asset(
              "assets/images/${name}_logo.svg",
              height: 55,
              width: 55,
            ),
            name: name,
            link: link) {
    ;
  }
}
