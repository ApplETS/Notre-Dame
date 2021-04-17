// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// OTHER
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class GradeNotAvailable extends StatelessWidget {
  const GradeNotAvailable();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Column(
              children: [
                const Icon(
                  Icons.school,
                  size: 100,
                  color: AppTheme.etsLightRed,
                ),
                Text(
                  AppIntl.of(context).grades_msg_no_grades,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
