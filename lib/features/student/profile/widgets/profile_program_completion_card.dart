import 'package:flutter/material.dart';
import 'package:notredame/features/student/profile/profile_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Card getProgramCompletionCard(ProfileViewModel model, BuildContext context) {
  return Card(
    child: SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppIntl.of(context)!.profile_program_completion,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 37.0),
              child: Center(child: getLoadingIndicator(model, context))),
        ],
      ),
    ),
  );
}

CircularPercentIndicator getLoadingIndicator(
    ProfileViewModel model, BuildContext context) {
  final double percentage = model.programProgression;

  return CircularPercentIndicator(
    animation: true,
    animationDuration: 1100,
    radius: 40,
    lineWidth: 10,
    percent: percentage / 100,
    circularStrokeCap: CircularStrokeCap.round,
    center: Text(
      percentage != 0
          ? '$percentage%'
          : AppIntl.of(context)!.profile_program_completion_not_available,
      style: const TextStyle(fontSize: 20),
    ),
    progressColor: Colors.green,
  );
}
