// FLUTTER / DART / THIRD-PARTIES
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';

// UTILS
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/utils/loading.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/faq_viewmodel.dart';

// CONSTANTS
import 'package:notredame/core/constants/feedback_type.dart';

class FaqView extends StatefulWidget {
  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<FaqViewModel>.reactive(
        viewModelBuilder: () => FaqViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) {
          final bool isLightMode =
              Theme.of(context).brightness == Brightness.light;
          return Scaffold(
            body: ListView(
              children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Icon(
                              Icons.arrow_back,
                              color: isLightMode ? Colors.black87 : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          AppIntl.of(context).need_help,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline5.copyWith(
                            color: isLightMode ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                getSubtitle(
                  AppIntl.of(context).questions_and_answers, 
                  isLightMode ? Colors.black87 : Colors.white
                ),
                getSubtitle(
                  AppIntl.of(context).actions, 
                  isLightMode ? Colors.black87 : Colors.white
                ),
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
                    child: getCardInfo(
                      context,
                      AppIntl.of(context).more_report_bug_feature,
                      AppIntl.of(context).more_report_bug_feature_subtitle,
                      Icons.design_services,
                      const Color.fromRGBO(63, 219, 251, 1),
                      const Color.fromRGBO(14, 127, 188, 1),
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

  Row getCardInfo(BuildContext context, String title, String subtitle,
      IconData icon, Color iconColor, Color circleColor) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: circleColor,
              radius: 25,
              child: Icon(icon, color: iconColor),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 19),
                  textAlign: TextAlign.left,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 16),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Padding getSubtitle(String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
      child: Text(
          subtitle,
          style: Theme.of(context).textTheme.headline5.copyWith(
            color: color,
          ),
        ),
    );
  }

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
