// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/student/profile/view_model/profile_viewmodel.dart';

class ProgramCompletionCard extends StatelessWidget {
  final ProfileViewModel model;

  const ProgramCompletionCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppIntl.of(context)!.profile_program_completion,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: model.programProgression / 100),
                    duration: const Duration(milliseconds: 900),
                    builder: (_, value, __) => SizedBox.square(
                      dimension: 75,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(context.theme.appColors.positive),
                      ),
                    ),
                  ),
                  Text(
                    model.programProgression > 0
                        ? '${model.programProgression}%'
                        : AppIntl.of(context)!.profile_program_completion_not_available,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
