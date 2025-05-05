// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/more/faq/widgets/carousel.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/core/ui/need_help_notice_dialog.dart';
import 'package:notredame/ui/more/faq/models/faq.dart';
import 'package:notredame/ui/more/faq/models/faq_actions.dart';
import 'package:notredame/ui/more/faq/view_model/faq_viewmodel.dart';
import 'package:notredame/ui/more/faq/widgets/action_card.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final Faq faq = Faq();

  @override
  Widget build(BuildContext context) => ViewModelBuilder<FaqViewModel>.reactive(
        viewModelBuilder: () => FaqViewModel(),
        builder: (context, model, child) {
          return BaseScaffold(
            safeArea: false,
            appBar: AppBar(
              title: Text(AppIntl.of(context)!.need_help),
            ),
            showBottomBar: false,
            body: (MediaQuery.of(context).orientation == Orientation.portrait)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      getSubtitle(AppIntl.of(context)!.questions_and_answers),
                      Carousel(),
                      getSubtitle(AppIntl.of(context)!.actions),
                      getActions(model)
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          children: [
                            getSubtitle(AppIntl.of(context)!.questions_and_answers),
                            Expanded(child: Carousel()),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            getSubtitle(AppIntl.of(context)!.actions),
                            Container(child: getActions(model)),
                          ],
                        ),
                      )
                    ],
                  ),
          );
        },
      );

  Widget getSubtitle(String subtitle) {
    return Padding(
      padding: EdgeInsets.only(top: 18.0, bottom: 10.0),
      child: Text(subtitle, style: Theme.of(context).textTheme.headlineSmall!),
    );
  }

  Widget getActions(FaqViewModel model) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 32.0),
        itemCount: faq.actions.length,
        itemBuilder: (context, index) {
          final action = faq.actions[index];
          return ActionCard(
            title: action.title,
            description: action.description,
            type: action.type,
            link: action.link,
            iconName: action.iconName,
            iconColor: action.iconColor,
            circleColor: action.circleColor,
            onTap: () {
              if (action.type == ActionType.webview) {
                model.launchWebsite(action.link);
              } else if (action.type == ActionType.email) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NeedHelpNoticeDialog(
                      openMail: () => model.openMail(action.link, context),
                      launchWebsite: () => model.launchPasswordReset(),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
