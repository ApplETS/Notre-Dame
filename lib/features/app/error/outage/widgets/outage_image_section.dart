// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../theme/app_palette.dart';

class OutageImageSection extends StatelessWidget {
  const OutageImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: 'ets_logo',
        child: Image.asset(
          "assets/animations/outage.gif",
          excludeFromSemantics: true,
          width: 500,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : AppPalette.etsLightRed,
        ));
  }
}
