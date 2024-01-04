// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/constants/faq.dart';
import 'package:notredame/core/models/faq_actions.dart';
import 'package:notredame/core/viewmodels/faq_viewmodel.dart';

class FaqView extends StatefulWidget {
  final Color? backgroundColor;

  const FaqView({this.backgroundColor});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final Faq faq = Faq();

  @override
  Widget build(BuildContext context) => ViewModelBuilder<FaqViewModel>.reactive(
        viewModelBuilder: () => FaqViewModel(),
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: widget.backgroundColor,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getTitle(),
                getSubtitle(AppIntl.of(context)!.questions_and_answers),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 250.0,
                    ),
                    items: faq.questions.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final question = faq.questions[index];

                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color.fromARGB(255, 240, 238, 238)
                                  : const Color.fromARGB(255, 40, 40, 40),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8.0)),
                            ),
                            child: getQuestionCard(
                              question.title[model.locale?.languageCode] ?? '',
                              question.description[model.locale?.languageCode] ?? '',
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                getSubtitle(AppIntl.of(context)!.actions),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 1.0),
                    itemCount: faq.actions.length,
                    itemBuilder: (context, index) {
                      final action = faq.actions[index];

                      return getActionCard(
                          action.title[model.locale?.languageCode] ?? '',
                          action.description[model.locale?.languageCode] ?? '',
                          action.type,
                          action.link,
                          action.iconName,
                          action.iconColor,
                          action.circleColor,
                          context,
                          model);
                    },
                  ),
                )
              ],
            ),
          );
        },
      );

  Padding getTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Icon(
                  Icons.arrow_back,
                  color: widget.backgroundColor == Colors.white
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              AppIntl.of(context)!.need_help,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: widget.backgroundColor == Colors.white
                        ? Colors.black
                        : Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Padding getSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, top: 18.0, bottom: 10.0),
      child: Text(
        subtitle,
        style: Theme.of(context).textTheme.headline5!.copyWith(
              color: widget.backgroundColor == Colors.white
                  ? Colors.black
                  : Colors.white,
            ),
      ),
    );
  }

  Padding getQuestionCard(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              textScaleFactor: 1.0,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontSize: 20,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20.0),
            Text(
              description,
              textScaleFactor: 1.0,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Padding getActionCard(
      String title,
      String description,
      ActionType type,
      String link,
      IconData iconName,
      Color iconColor,
      Color circleColor,
      BuildContext context,
      FaqViewModel model) {
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
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
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
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
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
