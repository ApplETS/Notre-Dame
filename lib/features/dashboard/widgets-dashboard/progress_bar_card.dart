import 'package:flutter/material.dart';
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProgressBarCard extends StatefulWidget {
  final DashboardViewModel model;
  final PreferencesFlag flag;
  final Text? progressBarText;
  final VoidCallback dismissCard;
  final VoidCallback changeProgressBarText;
  final VoidCallback setText;

  const ProgressBarCard({
    required this.model,
    required this.flag,
    required this.progressBarText,
    required this.dismissCard,
    required this.changeProgressBarText,
    required this.setText,
    super.key,
  });

  @override
  _ProgressBarCardState createState() => _ProgressBarCardState();
}

class _ProgressBarCardState extends State<ProgressBarCard> {
  @override
  Widget build(BuildContext context) {
    return DismissibleCard(
      isBusy: widget.model.busy(widget.model.progress),
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) {
        widget.dismissCard();
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
              child: Text(AppIntl.of(context)!.progress_bar_title,
                  style: Theme.of(context).textTheme.titleLarge),
            )),
        if (widget.model.progress >= 0.0)
          Stack(children: [
            Container(
              padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: GestureDetector(
                  onTap: () => setState(() {
                    widget.changeProgressBarText();
                    widget.setText();
                  }),
                  child: LinearProgressIndicator(
                    value: widget.model.progress,
                    minHeight: 30,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.gradeGoodMax),
                    backgroundColor: AppTheme.etsDarkGrey,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                widget.changeProgressBarText();
                widget.setText();
              }),
              child: Container(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: widget.progressBarText ??
                      Text(
                        AppIntl.of(context)!.progress_bar_message(
                            widget.model.sessionDays[0], widget.model.sessionDays[1]),
                        style: const TextStyle(color: Colors.white),
                      ),
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
    );
  }
}
