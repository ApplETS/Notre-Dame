// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/domain/constants/urls.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class GradeNotAvailable extends StatelessWidget {
  final VoidCallback? onPressed;
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  final bool isEvaluationPeriod;

  GradeNotAvailable({super.key, this.onPressed, this.isEvaluationPeriod = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flex(
            direction: (MediaQuery.of(context).orientation == Orientation.portrait) ? Axis.vertical : Axis.horizontal,
            spacing: 32.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, size: 100, color: AppPalette.etsLightRed),
              Flexible(
                child: Text(
                  isEvaluationPeriod
                      ? AppIntl.of(context)!.grades_error_course_evaluations_not_completed
                      : AppIntl.of(context)!.grades_msg_no_grade,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: isEvaluationPeriod
                      ? Theme.of(context).textTheme.bodyLarge
                      : Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16.0,
            children: [
              if (isEvaluationPeriod)
                FilledButton.icon(
                  icon: const Icon(Icons.star),
                  label: Text(AppIntl.of(context)!.grades_complete_evaluations),
                  onPressed: () => _launchUrlService.launchInBrowser(Urls.courseReviews),
                ),
              ElevatedButton.icon(
                style: isEvaluationPeriod
                    ? null
                    : ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.etsLightRed,
                        foregroundColor: AppPalette.grey.white,
                      ),
                onPressed: onPressed,
                icon: const Icon(Icons.refresh),
                label: Text(AppIntl.of(context)!.retry),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
