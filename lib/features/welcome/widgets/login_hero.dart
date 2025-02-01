import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/app_palette.dart';

class LoginHero extends StatefulWidget{

  const LoginHero(
      {super.key});

  @override
  State<LoginHero> createState() => _LoginHeroState();
}

class _LoginHeroState extends State<LoginHero>{

  @override
  Widget build(BuildContext context) => Hero(
          tag: 'ets_logo',
          child: SvgPicture.asset(
            "assets/images/ets_white_logo.svg",
            excludeFromSemantics: true,
            width: 90,
            height: 90,
            colorFilter: ColorFilter.mode(
                Theme.of(context).brightness ==
                    Brightness.light
                    ? Colors.white
                    : AppPalette.etsLightRed,
                BlendMode.srcIn),
          ));
}
