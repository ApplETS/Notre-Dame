// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
// GENERATED
import 'package:notredame/generated/l10n.dart';

class ApplETSWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.appletsPurple,
      child: Column(children: <Widget>[
        Text(AppIntl.of(context).card_applets_title,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            )),
        Text(
          AppIntl.of(context).card_applets_text,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ]),
    );
  }
}
