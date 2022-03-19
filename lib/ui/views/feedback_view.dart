// FLUTTER / DART / THIRD-PARTIES
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/viewmodels/feedback_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// OTHERS
import 'package:notredame/ui/widgets/base_scaffold.dart';

class FeedbackView extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<FeedbackViewModel>.reactive(
        viewModelBuilder: () => FeedbackViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) {
          return BaseScaffold(
              appBar: AppBar(
                title: Text(AppIntl.of(context).more_report_bug),
              ),
              showBottomBar: false,
              body: ListView(children: <Widget>[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText1,
                      children: <TextSpan>[
                        TextSpan(
                            text:
                                AppIntl.of(context).more_report_bug_steps_title,
                            style: const TextStyle(fontSize: 32)),
                        TextSpan(
                            text: AppIntl.of(context).more_report_bug_step1,
                            style: const TextStyle(fontSize: 24)),
                        TextSpan(
                            text: AppIntl.of(context).more_report_bug_step2,
                            style: const TextStyle(fontSize: 24)),
                        TextSpan(
                            text: AppIntl.of(context).more_report_bug_step3,
                            style: const TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    child: Text(AppIntl.of(context).more_report_bug_button),
                    onPressed: () =>
                        BetterFeedback.of(context).show((feedback) {
                      model
                          .sendFeedback(
                              feedback.text,
                              feedback.screenshot,
                              feedback.extra.entries.first.value
                                  .toString()
                                  .split('.')
                                  .last)
                          .then((value) => BetterFeedback.of(context).hide());
                    }),
                  ),
                ),
              ]));
        },
      );
}
