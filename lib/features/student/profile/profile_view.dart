// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/student/profile/widgets/profile_balance_card.dart';
import 'package:notredame/features/student/profile/widgets/profile_infos_card.dart';
import 'package:notredame/features/student/profile/widgets/profile_main_infos_card.dart';
import 'package:notredame/features/student/profile/widgets/profile_current_program_tile.dart';
import 'package:notredame/features/student/profile/widgets/profile_program_completion_card.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/student/profile/profile_viewmodel.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/loading.dart';
import 'package:notredame/features/student/widgets/student_program.dart';

class ProfileView extends StatefulWidget {
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  @override
  void initState() {
    super.initState();

    _analyticsService.logEvent("ProfileView", "Opened");
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ProfileViewModel>.reactive(
        viewModelBuilder: () => ProfileViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) {
          return RefreshIndicator(
            onRefresh: () => model.refresh(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (model.isBusy)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child:
                          buildLoading(isInteractionLimitedWhileLoading: false),
                    )
                  else
                    buildPage(context, model)
                ],
              ),
            ),
          );
        },
      );
}

Widget buildPage(BuildContext context, ProfileViewModel model) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
          child: getMainInfoCard(model),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                    child: getMyInfosCard(model, context),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                    child: getMyBalanceCard(model, context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 4.0),
                    child: getProgramCompletionCard(model, context),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(
          thickness: 2,
          indent: 10,
          endIndent: 10,
        ),
        getCurrentProgramTile(model.programList, context),
        const Divider(
          thickness: 2,
          indent: 10,
          endIndent: 10,
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text(
                AppIntl.of(context)!.profile_other_programs,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.etsLightRed),
              ),
            ),
          ],
        ),
        Column(
          children: [
            for (var i = 0; i < model.programList.length - 1; i++)
              StudentProgram(model.programList[i]),
          ],
        ),
        const SizedBox(height: 10.0),
      ],
    );
