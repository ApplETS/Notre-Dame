// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/domain/constants/app_info.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/core/ui/carousel.dart';
import 'package:notredame/ui/core/ui/need_help_notice_dialog.dart';
import 'package:notredame/ui/more/faq/view_model/faq_viewmodel.dart';
import 'package:notredame/ui/more/faq/widgets/action_card.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
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
                      getSubtitle(AppIntl.of(context)!.faq_questions),
                      _carousel(),
                      getSubtitle(AppIntl.of(context)!.faq_actions),
                      _getActions(model)
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          children: [getSubtitle(AppIntl.of(context)!.faq_questions), _carousel()],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            getSubtitle(AppIntl.of(context)!.faq_actions),
                            Container(child: _getActions(model)),
                          ],
                        ),
                      )
                    ],
                  ),
          );
        },
      );

  Widget getSubtitle(String subtitle) => Padding(
        padding: EdgeInsets.only(top: 18.0, bottom: 10.0),
        child: Text(subtitle, style: Theme.of(context).textTheme.headlineSmall!),
      );

  Widget _carousel() => Carousel(
        controller: PageController(viewportFraction: 0.90),
        children: [
          _questionCard(AppIntl.of(context)!.faq_questions_no_access_title,
              AppIntl.of(context)!.faq_questions_no_access_description),
          _questionCard(AppIntl.of(context)!.faq_questions_no_grades_title,
              AppIntl.of(context)!.faq_questions_no_grades_description)
        ],
      );

  Widget _questionCard(String title, String description) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12.0,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 20,
                  ),
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
          ],
        ),
      ));

  Widget _getActions(FaqViewModel model) => Expanded(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32.0),
          children: [
            ActionCard(
                title: AppIntl.of(context)!.faq_actions_reactivate_account_title,
                description: AppIntl.of(context)!.faq_actions_reactivate_account_description,
                iconName: Icons.school,
                iconColor: const Color(0xFF78E2BC),
                circleColor: const Color(0xFF39B78A),
                onTap: () => model.launchWebsite("https://formulaires.etsmtl.ca/ReactivationCompte")),
            ActionCard(
                title: AppIntl.of(context)!.faq_actions_contact_registrar_title,
                description: AppIntl.of(context)!.faq_actions_contact_registrar_description,
                iconName: Icons.email,
                iconColor: const Color(0xFFFCA4A4),
                circleColor: const Color(0xFFDA4444),
                onTap: () => model.openMail("accueilbdr@etsmtl.ca", context)),
            ActionCard(
                title: AppIntl.of(context)!.faq_actions_contact_applets_title,
                description: AppIntl.of(context)!.faq_actions_contact_applets_description,
                iconName: Icons.install_mobile,
                iconColor: const Color(0xFF71D8F7),
                circleColor: const Color(0xFF397DB7),
                onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NeedHelpNoticeDialog(
                          openMail: () => model.openMail(AppInfo.email, context),
                          launchWebsite: () => model.launchPasswordReset(),
                        );
                      },
                    ))
          ],
        ),
      );
}
