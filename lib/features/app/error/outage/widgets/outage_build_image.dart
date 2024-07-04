import 'package:flutter/material.dart';
import 'package:notredame/utils/app_theme.dart';

Widget outageImageSection(BuildContext context) {
  return Hero(
      tag: 'ets_logo',
      child: Image.asset(
        "assets/animations/outage.gif",
        excludeFromSemantics: true,
        width: 500,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : AppTheme.etsLightRed,
      ));
}
