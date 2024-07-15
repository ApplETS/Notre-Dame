// widgets/AppletsLogo.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppEtsLogo extends StatelessWidget {
  const AppEtsLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: -20,
      children: <Widget>[
        Text(
          AppIntl.of(context)!.login_applets_logo,
          style: const TextStyle(color: Colors.white),
        ),
        Image.asset(
          'assets/images/applets_white_logo.png',
          excludeFromSemantics: true,
          width: 100,
          height: 100,
        ),
      ],
    );
  }
}
