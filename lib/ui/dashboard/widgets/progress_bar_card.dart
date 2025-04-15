// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import '../../core/themes/app_palette.dart';

class ProgressBarCard extends StatelessWidget {
  final VoidCallback onDismissed;
  final VoidCallback changeProgressBarText;
  final String progressBarText;
  final double progress;
  final bool loading;

  const ProgressBarCard(
      {super.key,
      required this.onDismissed,
      required this.progressBarText,
      required this.changeProgressBarText,
      required this.progress,
      required this.loading});

  @override
  Widget build(BuildContext context) => DismissibleCard(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) => onDismissed(),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: Text(AppIntl.of(context)!.progress_bar_title, style: Theme.of(context).textTheme.titleLarge),
              )),
          if (loading || progress >= 0.0)
            Skeletonizer(
              enabled: loading,
              ignoreContainers: true,
              child: Stack(children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: GestureDetector(
                      onTap: () => changeProgressBarText(),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 30,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.gradeGoodMax),
                        backgroundColor: AppPalette.grey.darkGrey,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => changeProgressBarText(),
                  child: Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        progressBarText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ]),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(AppIntl.of(context)!.session_without),
              ),
            ),
        ]),
      );
}
