// FLUTTER / DART / THIRD-PARTIES
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/utils/loading.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/feedback_viewmodel.dart';

class FeedbackView extends StatefulWidget {
  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<FeedbackViewModel>.reactive(
        viewModelBuilder: () => FeedbackViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) {
          final bool isLightMode =
              Theme.of(context).brightness == Brightness.light;
          return Scaffold(
            appBar: AppBar(
              title: Text(AppIntl.of(context).more_report_bug),
            ),
            body: ListView(
              children: <Widget>[
                const SizedBox(height: 8),
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(AppIntl.of(context).my_tickets,
                        style: Theme.of(context).textTheme.headline4.copyWith(
                            color:
                                isLightMode ? Colors.black87 : Colors.white))),
                const Divider(
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
                const SizedBox(height: 8),
                if (model.myIssues.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: model.myIssues.length,
                    itemBuilder: (context, index) {
                      final bool isLightMode =
                          Theme.of(context).brightness == Brightness.light;
                      return GestureDetector(
                        onTap: () => {
                          Utils.launchURL(model.myIssues[index].htmlUrl,
                              AppIntl.of(context))
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              right: 12, left: 12, bottom: 8),
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 8.0, top: 8.0, bottom: 8.0),
                          decoration: BoxDecoration(
                            color: isLightMode
                                ? Colors.black12
                                : AppTheme.etsDarkGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      model.myIssues[index].simpleDescription,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: isLightMode
                                              ? const Color.fromARGB(
                                                  168, 0, 0, 0)
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Row(children: [
                                    createListTag(
                                      model.myIssues[index].createdAt,
                                      color: Colors.transparent,
                                      textColor: isLightMode
                                          ? const Color.fromARGB(168, 0, 0, 0)
                                          : Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    createListTag(
                                        model.myIssues[index].isOpen
                                            ? AppIntl.of(context)
                                                .ticket_status_open
                                            : AppIntl.of(context)
                                                .ticket_status_closed,
                                        color: model.myIssues[index].state ==
                                                'open'
                                            ? Colors.green
                                            : Colors.red,
                                        textColor: Colors.white),
                                  ]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: model.isBusy
                                  ? buildLoading(
                                      isInteractionLimitedWhileLoading: false)
                                  : Text(
                                      AppIntl.of(context).no_ticket,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(color: Colors.black38),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  Widget createListTag(String text, {Color textColor, Color color}) {
    return Container(
      decoration: BoxDecoration(
          // border radius
          borderRadius: BorderRadius.circular(6),
          color: color),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
