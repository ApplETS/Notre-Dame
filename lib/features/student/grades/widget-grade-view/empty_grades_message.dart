// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmptyGradesMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppIntl.of(context)!.grades_msg_no_grades,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
