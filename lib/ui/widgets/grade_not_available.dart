// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// OTHER
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class GradeNotAvailable extends StatelessWidget {
  final VoidCallback onPressed;

  final bool isEvaluationPeriod;

  const GradeNotAvailable(
      {Key key, this.onPressed, this.isEvaluationPeriod = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.school,
          size: 100,
          color: AppTheme.etsLightRed,
        ),
        const SizedBox(height: 25),
        Text(
          isEvaluationPeriod
              ? AppIntl.of(context)
                  .grades_error_course_evaluations_not_completed
              : AppIntl.of(context).grades_msg_no_grades,
          textAlign: TextAlign.center,
          softWrap: true,
          style: isEvaluationPeriod
              ? Theme.of(context).textTheme.bodyText1
              : Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 25),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(AppTheme.etsLightRed)),
            onPressed: onPressed,
            child: Text(AppIntl.of(context).retry))
      ],
    );
  }
}
