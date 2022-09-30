// FLUTTER / DART / THIRD-PARTIES
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/utils/utils.dart';
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
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(AppIntl.of(context).my_tickets,
                        style: Theme.of(context).textTheme.headline4)),
                const SizedBox(height: 8),
                // List of myIssues but with a better design (left, the time of the creation, right the state of the issue)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: model.myIssues.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(model.myIssues[index].createdAt.toString()),
                      trailing: Text(model.myIssues[index].state.toString(),
                          style: TextStyle(
                              color: model.myIssues[index].state == 'open'
                                  ? Colors.green
                                  : Colors.red)),
                      onTap: () => Utils.launchURL(
                          model.myIssues[index].htmlUrl, AppIntl.of(context)),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => BetterFeedback.of(context).show((feedback) {
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
              label: Text(AppIntl.of(context).more_report_bug_button),
            ),
          );
        },
      );
}
