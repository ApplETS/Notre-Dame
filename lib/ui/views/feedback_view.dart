// FLUTTER / DART / THIRD-PARTIES
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/feedback_viewmodel.dart';

// OTHERS
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          return Scaffold(
            appBar: AppBar(
              title: Text(AppIntl.of(context).more_report_bug),
            ),
            body: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  Card(
                    color: Theme.of(context).brightness == Brightness.light ? AppTheme.lightThemeBackground : AppTheme.darkThemeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: AppTheme.etsLightGrey.withOpacity(0.1)),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        BetterFeedback.of(context).show((feedback) {
                          model.sendFeedback(
                                feedback.text,
                                feedback.screenshot,
                                feedback.extra.entries.first.value
                                    .toString()
                                    .split('.')
                                    .last)
                            .then((value) => BetterFeedback.of(context).hide());
                        });
                      }, 
                      style: ElevatedButton.styleFrom(primary: Theme.of(context).brightness == Brightness.light ? AppTheme.lightThemeBackground : AppTheme.darkThemeAccent, padding: EdgeInsets.zero),
                      child: getCardInfo(
                        context,
                        AppIntl.of(context).more_report_bug_bug,
                        AppIntl.of(context).more_report_bug_bug_subtitle,
                        Icons.bug_report,
                        const Color.fromRGBO(252, 196, 238, 1),
                        const Color.fromRGBO(153, 78, 174, 1),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: AppTheme.etsLightGrey.withOpacity(0.1)),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        BetterFeedback.of(context).show((feedback) {
                          model.sendFeedback(
                                feedback.text,
                                feedback.screenshot,
                                feedback.extra.entries.first.value
                                    .toString()
                                    .split('.')
                                    .last)
                            .then((value) => BetterFeedback.of(context).hide());
                        });
                      }, 
                      style: ElevatedButton.styleFrom(primary: Theme.of(context).brightness == Brightness.light ? AppTheme.lightThemeBackground : AppTheme.darkThemeAccent, padding: EdgeInsets.zero),
                      child: getCardInfo(
                        context,
                        AppIntl.of(context).more_report_bug_feature,
                        AppIntl.of(context).more_report_bug_feature_subtitle,
                        Icons.design_services,
                        const Color.fromRGBO(63, 219, 251, 1),
                        const Color.fromRGBO(14, 127, 188, 1)
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: AppIntl.of(context).more_report_tips, style: Theme.of(context).textTheme.headline5),
                          TextSpan(text: AppIntl.of(context).more_report_bug_step1, style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 18)),
                          TextSpan(text: AppIntl.of(context).more_report_bug_step2, style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 18, 
                            color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(14, 127, 188, 1) : const Color.fromRGBO(63, 219, 251, 1))),
                          TextSpan(text: AppIntl.of(context).more_report_bug_step3, style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 18)),
                          TextSpan(text: AppIntl.of(context).more_report_bug_step4, style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 18, 
                            color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(14, 127, 188, 1) : const Color.fromRGBO(63, 219, 251, 1))),
                          TextSpan(text: AppIntl.of(context).more_report_bug_step5, style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Padding getCardInfo(BuildContext context, String title, String subtitle, IconData icon, Color iconColor, Color circleColor) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CircleAvatar(
              backgroundColor: circleColor,
              radius: 25,
              child: Icon(icon, color: iconColor),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize:MainAxisSize.min,
                crossAxisAlignment:CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.left,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
