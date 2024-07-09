import 'package:flutter/material.dart';
import 'package:notredame/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradesSummary extends StatelessWidget {
  final double? currentGrade;
  final double? maxGrade;
  final String recipient;
  final Color color;

  const GradesSummary({
    required this.currentGrade,
    required this.maxGrade,
    required this.recipient,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
              AppIntl.of(context)!.grades_grade_with_percentage(
                currentGrade ?? 0.0,
                maxGrade ?? 0.0,
                Utils.getGradeInPercentage(
                  currentGrade,
                  maxGrade,
                ),
              ),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: color)),
        ),
        Text(recipient,
            style:
                Theme.of(context).textTheme.bodyLarge!.copyWith(color: color)),
      ],
    );
  }
}
