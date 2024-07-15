// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/features/more/faq/faq_viewmodel.dart';
import 'package:notredame/features/more/faq/models/faq_actions.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final ActionType type;
  final String link;
  final IconData iconName;
  final Color iconColor;
  final Color circleColor;
  final BuildContext context;
  final FaqViewModel model;

  const ActionCard({
    required this.title,
    required this.description,
    required this.type,
    required this.link,
    required this.iconName,
    required this.iconColor,
    required this.circleColor,
    required this.context,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
      child: ElevatedButton(
        onPressed: () {
          if (type.name == ActionType.webview.name) {
            openWebview(model, link);
          } else if (type.name == ActionType.email.name) {
            openMail(model, context, link);
          }
        },
        style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(8.0),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            )),
        child: getActionCardInfo(
          context,
          title,
          description,
          iconName,
          iconColor,
          circleColor,
        ),
      ),
    );
  }

  Row getActionCardInfo(BuildContext context, String title, String description,
      IconData iconName, Color iconColor, Color circleColor) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: circleColor,
              radius: 25,
              child: Icon(iconName, color: iconColor),
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
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 18,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10.0),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                  textAlign: TextAlign.justify,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> openWebview(FaqViewModel model, String link) async {
    model.launchWebsite(link, Theme.of(context).brightness);
  }

  Future<void> openMail(
      FaqViewModel model, BuildContext context, String addressEmail) async {
    model.openMail(addressEmail, context);
  }
}
