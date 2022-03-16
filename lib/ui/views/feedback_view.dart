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
              body: Column(children: <Widget>[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 24,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'How does it work?\n\n',
                            style: TextStyle(fontSize: 32)),
                        TextSpan(
                            text:
                                '1. Just press the `Provide feedback` button.\n\n'),
                        TextSpan(
                            text: '2. The feedback view opens. '
                                'You can choose between draw and navigation mode. '
                                'When in navigate mode, you can freely navigate in the '
                                'app. To switch to the drawing mode just press the `Draw` button on the right '
                                'side. Now you can draw on the screen.\n\n'),
                        TextSpan(
                            text:
                                '3. To finish your feedback just write a message '
                                'below and send it by pressing the `Submit` button.\n\n'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  child: const Text('Provide feedback'),
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
                ),
              ]));
        },
      );
}
