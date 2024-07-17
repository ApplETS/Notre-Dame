// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feedback/feedback.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/more/feedback/feedback_type.dart';
import 'package:notredame/features/more/feedback/feedback_viewmodel.dart';
import 'package:notredame/features/more/feedback/widgets-feedback/card_info.dart';
import 'package:notredame/features/more/feedback/widgets-feedback/list_tag.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/loading.dart';
import 'package:notredame/utils/utils.dart';

class FeedbackView extends StatefulWidget {
  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<FeedbackViewModel>.reactive(
        viewModelBuilder: () => FeedbackViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) {
          final bool isLightMode =
              Theme.of(context).brightness == Brightness.light;
          return Scaffold(
            appBar: AppBar(
              title: Text(AppIntl.of(context)!.more_report_bug),
            ),
            body: ListView(
              children: <Widget>[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      BetterFeedback.of(context).show((feedback) {
                        model
                            .sendFeedback(feedback, FeedbackType.bug)
                            .then((value) => BetterFeedback.of(context).hide());
                      });
                    },
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    )),
                    child: CardInfo(
                      title: AppIntl.of(context)!.more_report_bug_bug,
                      subtitle:
                          AppIntl.of(context)!.more_report_bug_bug_subtitle,
                      icon: Icons.bug_report,
                      iconColor: const Color.fromRGBO(252, 196, 238, 1),
                      circleColor: const Color.fromRGBO(153, 78, 174, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      BetterFeedback.of(context).show((feedback) {
                        model
                            .sendFeedback(feedback, FeedbackType.enhancement)
                            .then((value) => BetterFeedback.of(context).hide());
                      });
                    },
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    )),
                    child: CardInfo(
                      title: AppIntl.of(context)!.more_report_bug_feature,
                      subtitle:
                          AppIntl.of(context)!.more_report_bug_feature_subtitle,
                      icon: Icons.design_services,
                      iconColor: const Color.fromRGBO(63, 219, 251, 1),
                      circleColor: const Color.fromRGBO(14, 127, 188, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(AppIntl.of(context)!.my_tickets,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                                color: isLightMode
                                    ? Colors.black87
                                    : Colors.white))),
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
                              AppIntl.of(context)!)
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
                                    ListTag(
                                      text: model.myIssues[index].createdAt,
                                      color: Colors.transparent,
                                      textColor: isLightMode
                                          ? const Color.fromARGB(168, 0, 0, 0)
                                          : Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    ListTag(
                                        text: model.myIssues[index].isOpen
                                            ? AppIntl.of(context)!
                                                .ticket_status_open
                                            : AppIntl.of(context)!
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
                                      AppIntl.of(context)!.no_ticket,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color: isLightMode
                                                  ? const Color.fromARGB(
                                                      168, 0, 0, 0)
                                                  : Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 25),
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(AppIntl.of(context)!.more_report_tips,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                                color: isLightMode
                                    ? Colors.black87
                                    : Colors.white))),
                const Divider(
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: AppIntl.of(context)!.more_report_bug_step1,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontSize: 18)),
                        TextSpan(
                            text: AppIntl.of(context)!.more_report_bug_step2,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontSize: 18,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? const Color.fromRGBO(14, 127, 188, 1)
                                        : const Color.fromRGBO(
                                            63, 219, 251, 1))),
                        TextSpan(
                            text: AppIntl.of(context)!.more_report_bug_step3,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontSize: 18)),
                        TextSpan(
                            text: AppIntl.of(context)!.more_report_bug_step4,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontSize: 18,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? const Color.fromRGBO(14, 127, 188, 1)
                                        : const Color.fromRGBO(
                                            63, 219, 251, 1))),
                        TextSpan(
                            text: AppIntl.of(context)!.more_report_bug_step5,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

  Color getColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppTheme.lightThemeBackground
        : AppTheme.darkThemeAccent;
  }
}
