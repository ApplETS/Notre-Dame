// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';

class GradeNotAvailable extends StatelessWidget {
  final VoidCallback? onPressed;

  final bool isEvaluationPeriod;

  const GradeNotAvailable({super.key, this.onPressed, this.isEvaluationPeriod = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.school,
            size: 100,
            color: AppPalette.etsLightRed,
          ),
          const SizedBox(height: 25),
          Text(
            isEvaluationPeriod
                ? AppIntl.of(context)!.grades_error_course_evaluations_not_completed
                : AppIntl.of(context)!.grades_msg_no_grade,
            textAlign: TextAlign.center,
            softWrap: true,
            style: isEvaluationPeriod ? Theme.of(context).textTheme.bodyLarge : Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 25),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.etsLightRed, foregroundColor: AppPalette.grey.white),
              onPressed: onPressed,
              child: Text(AppIntl.of(context)!.retry))
        ],
      ),
    );
  }
}
