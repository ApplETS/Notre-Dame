// FLUTTER / DART / THIRD-PARTIES
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/feedback_viewmodel.dart';

class FeedbackView extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<FeedbackViewModel>.reactive(
        viewModelBuilder: () => FeedbackViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) {
          bool _hasSubmitted = false;
          return Scaffold(
            appBar: AppBar(
              title: Text(AppIntl.of(context).more_report_bug),
            ),
            body: ListView(
              children: <Widget>[
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
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => BetterFeedback.of(context).show((feedback) {
                if (!_hasSubmitted) {
                  _hasSubmitted = true;
                  model
                      .sendFeedback(feedback)
                      .then((value) => BetterFeedback.of(context).hide());
                }
              }),
              label: Text(AppIntl.of(context).more_report_bug_button),
            ),
          );
        },
      );
}
