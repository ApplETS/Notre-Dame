// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:notredame/utils/app_theme.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'ets_logo',
      child: SvgPicture.asset(
        "assets/images/ets_white_logo.svg",
        excludeFromSemantics: true,
        width: 90,
        height: 90,
        colorFilter: ColorFilter.mode(
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : AppTheme.etsLightRed,
            BlendMode.srcIn),
      ),
    );
  }
}
