// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/svg.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_theme.dart';

class LoginHero extends StatefulWidget {
  const LoginHero({super.key});

  @override
  State<LoginHero> createState() => _LoginHeroState();
}

class _LoginHeroState extends State<LoginHero> {
  @override
  Widget build(BuildContext context) => Hero(
      tag: 'ets_logo',
      child: SvgPicture.asset(
        "assets/images/ets_white_logo.svg",
        excludeFromSemantics: true,
        width: 90,
        height: 90,
        colorFilter: ColorFilter.mode(
            context.theme.appColors.loginAccent, BlendMode.srcIn),
      ));
}
