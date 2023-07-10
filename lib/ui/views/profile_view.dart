// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:percent_indicator/percent_indicator.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/profile_viewmodel.dart';

// MODEL
import 'package:ets_api_clients/models.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';

// WIDGETS
import 'package:notredame/ui/widgets/student_program.dart';

// UTILS
import 'package:notredame/ui/utils/loading.dart';

// OTHER
import 'package:notredame/locator.dart';

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
Widget build(BuildContext context) => ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(intl: AppIntl.of(context)),
      builder: (context, model, child) {
        return RefreshIndicator(
          onRefresh: () => model.refresh(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
                  child: SizedBox(
                    height: 90,
                    child: getMainInfoCard(model),
                  ),
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
                            child: getProgramCompletion(model, context),
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
                getCurrentProgramTile(model.programList[model.programList.length - 1], context),
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
                        AppIntl.of(context).profile_other_programs,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.etsLightRed
                        ),
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
                const SizedBox(
                  height: 10.0
                ),
                if (model.isBusy)
                  buildLoading(isInteractionLimitedWhileLoading: false)
                else
                  const SizedBox()
              ],
            ),
          ),
        );
      },
    );
}

Card getMainInfoCard(ProfileViewModel model) {
  return Card(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              '${model.profileStudent.firstName} ${model.profileStudent.lastName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'Génie logiciel',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Card getMyInfosCard(ProfileViewModel model, BuildContext context) {
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 3.0),
          child: Text(
            AppIntl.of(context).profile_permanent_code,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            model.profileStudent.permanentCode,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 3.0),
          child: Text(
            AppIntl.of(context).login_prompt_universal_code,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
          child: Text(
            model.universalAccessCode,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

Card getMyBalanceCard(ProfileViewModel model, BuildContext context) {
  final balance = model.profileStudent.balance;
  return Card( 
    color: double.parse(balance.substring(0, balance.length - 1).replaceAll(",", ".")) > 0 ? Colors.red : Colors.green,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 3.0),
          child: Text(
            AppIntl.of(context).profile_balance,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Center(
            child: Text(
              balance,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    ),
  );
}

Card getProgramCompletion(ProfileViewModel model, BuildContext context) {
  return Card(
    child: SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppIntl.of(context).profile_program_completion,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 37.0),
            child: Center(child: getLoadingIndicator()),
          )
        ],
      ),
    ),
  );
}

CircularPercentIndicator getLoadingIndicator() {
  return CircularPercentIndicator(
      animation: true,
      animationDuration: 1100,
      radius: 40,
      lineWidth: 10,
      percent: 0.88,
      circularStrokeCap: CircularStrokeCap.round,
      center: const Text(
          "88.0",
          style: TextStyle(fontSize: 20),
        ),
      progressColor: Colors.green,
    );
}

Column getCurrentProgramTile(Program program, BuildContext context) {
  final List<String> dataTitles = [
      AppIntl.of(context).profile_code_program,
      AppIntl.of(context).profile_average_program,
      AppIntl.of(context).profile_number_accumulated_credits_program,
      AppIntl.of(context).profile_number_registered_credits_program,
      AppIntl.of(context).profile_number_completed_courses_program,
      AppIntl.of(context).profile_number_failed_courses_program,
      AppIntl.of(context).profile_number_equivalent_courses_program,
      AppIntl.of(context).profile_status_program
    ];

    final List<String> dataFetched = [
      program.code,
      program.average,
      program.accumulatedCredits,
      program.registeredCredits,
      program.completedCourses,
      program.failedCourses,
      program.equivalentCourses,
      program.status
    ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Text(
          program.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.etsLightRed
          ),
        ),
      ),
      ...List<Widget>.generate(dataTitles.length, (index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(dataTitles[index]),
              Text(dataFetched[index]),
            ],
          ),
        );
      }),
    ],
  );

}
