import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/themes/app_palette.dart';

class ProgressBarCard extends StatelessWidget {
  final DashboardViewModel _model;
  final VoidCallback _onDismissed;

  const ProgressBarCard({super.key, required DashboardViewModel model, required VoidCallback onDismissed})
    : _model = model,
    _onDismissed = onDismissed;

  @override
  Widget build(BuildContext context) => DismissibleCard(
    key: UniqueKey(),
    onDismissed: (DismissDirection direction) => _onDismissed(),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
            child: Text(AppIntl.of(context)!.progress_bar_title,
                style: Theme.of(context).textTheme.titleLarge),
          )),
      if (_model.busy(_model.progress) || _model.progress >= 0.0)
        Skeletonizer(
          enabled: _model.busy(_model.progress),
          ignoreContainers: true,
          child: Stack(children: [
            Container(
              padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: GestureDetector(
                  onTap: () => _model.changeProgressBarText(),
                  child: LinearProgressIndicator(
                    value: _model.progress,
                    minHeight: 30,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppPalette.gradeGoodMax),
                    backgroundColor: AppPalette.grey.darkGrey,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _model.changeProgressBarText(),
              child: Container(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(_model.setProgressBarText(context),
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
  