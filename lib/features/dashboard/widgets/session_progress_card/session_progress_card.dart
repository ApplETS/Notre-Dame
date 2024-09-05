// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/widgets/session_progress_card/session_progress_card_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';

class SessionProgressCard extends StatelessWidget {
  final PreferencesFlag flag;
  final VoidCallback dismissCard;

  const SessionProgressCard(this.flag,{
    required this.dismissCard,
    required super.key,
  });

  @override
  Widget build(BuildContext context) => ViewModelBuilder<SessionProgressCardViewmodel>.reactive(
      viewModelBuilder: () => SessionProgressCardViewmodel(AppIntl.of(context)!),
      builder: (context, model, child) => DismissibleCard(
        isBusy: model.busy(model.data),
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) => dismissCard(),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: Text(AppIntl.of(context)!.progress_bar_title,
                    style: Theme.of(context).textTheme.titleLarge),
              )),
          if ((model.data ?? 0.0) >= 0.0)
            Stack(children: [
              Container(
                padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: GestureDetector(
                    onTap: () => model.updateProgressBarTextSetting(),
                    child: LinearProgressIndicator(
                      value: model.data ?? 0.0,
                      minHeight: 30,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.gradeGoodMax),
                      backgroundColor: AppTheme.etsDarkGrey,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => model.updateProgressBarTextSetting(),
                child: Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                      child: Text(model.progressBarText ?? "",
                        style: const TextStyle(color: Colors.white))
                  ),
                ),
              ),
            ])
          else
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(AppIntl.of(context)!.session_without),
              ),
            ),
        ]),
      ));
}
