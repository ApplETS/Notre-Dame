// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/more/faq/faq_viewmodel.dart';
import 'package:notredame/features/more/faq/models/faq.dart';
import 'package:notredame/features/more/faq/widget/action_card.dart';
import 'package:notredame/features/more/faq/widget/faq_subtitle.dart';
import 'package:notredame/features/more/faq/widget/faq_title.dart';
import 'package:notredame/features/more/faq/widget/question_card.dart';

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
                FaqTitle(backgroundColor: widget.backgroundColor),
                FaqSubtitle(
                  subtitle: AppIntl.of(context)!.questions_and_answers,
                  backgroundColor: widget.backgroundColor,
                ),
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
                            child: QuestionCard(
                              title:
                                  question.title[model.locale?.languageCode] ??
                                      '',
                              description: question.description[
                                      model.locale?.languageCode] ??
                                  '',
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                FaqSubtitle(
                  subtitle: AppIntl.of(context)!.actions,
                  backgroundColor: widget.backgroundColor,
                ),
                Expanded(
                  child: ListView.builder(
                    key: const Key("action_listview_key"),
                    padding: const EdgeInsets.only(top: 1.0),
                    itemCount: faq.actions.length,
                    itemBuilder: (context, index) {
                      final action = faq.actions[index];

                      return ActionCard(
                        title: action.title[model.locale?.languageCode] ?? '',
                        description:
                            action.description[model.locale?.languageCode] ??
                                '',
                        type: action.type,
                        link: action.link,
                        iconName: action.iconName,
                        iconColor: action.iconColor,
                        circleColor: action.circleColor,
                        context: context,
                        model: model,
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      );
}
