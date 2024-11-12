// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/signets-api/models/program.dart';
import 'package:notredame/features/student/profile/profile_viewmodel.dart';
import 'package:notredame/features/student/widgets/student_program.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/loading.dart';
import 'package:notredame/utils/locator.dart';

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

Card getMainInfoCard(ProfileViewModel model) {
  var programName = "";
  if (model.programList.isNotEmpty) {
    programName = model.programList.last.name;
  }

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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              programName,
              style: const TextStyle(
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
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: model.profileStudent.permanentCode));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppIntl.of(context)!
                    .profile_permanent_code_copied_to_clipboard),
              ));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    AppIntl.of(context)!.profile_permanent_code,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    model.profileStudent.permanentCode,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: model.universalAccessCode));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppIntl.of(context)!
                    .profile_universal_code_copied_to_clipboard),
              ));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 3.0),
                  child: Text(
                    AppIntl.of(context)!.login_prompt_universal_code,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Center(
                  child: Text(
                    model.universalAccessCode,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Card getMyBalanceCard(ProfileViewModel model, BuildContext context) {
  final stringBalance = model.profileStudent.balance;
  var balance = 0.0;

  if (stringBalance.isNotEmpty) {
    balance = double.parse(stringBalance
        .substring(0, stringBalance.length - 1)
        .replaceAll(",", "."));
  }

  return Card(
    color: balance > 0 ? Colors.red : Colors.green,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 3.0),
          child: Text(
            AppIntl.of(context)!.profile_balance,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Center(
            child: Text(
              stringBalance,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    ),
  );
}

Card getProgramCompletion(ProfileViewModel model, BuildContext context) {
  return Card(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppIntl.of(context)!.profile_program_completion,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: model.programProgression / 100),
                  duration: const Duration(milliseconds: 900),
                  builder: (_, value, __) => SizedBox.square(
                    dimension: 75,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation(Colors.green),
                    ),
                  ),
                ),
                Text(
                  model.programProgression > 0
                      ? '${model.programProgression}%'
                      : AppIntl.of(context)!
                          .profile_program_completion_not_available,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Column getCurrentProgramTile(List<Program> programList, BuildContext context) {
  if (programList.isNotEmpty) {
    final program = programList.last;

    final List<String> dataTitles = [
      AppIntl.of(context)!.profile_code_program,
      AppIntl.of(context)!.profile_average_program,
      AppIntl.of(context)!.profile_number_accumulated_credits_program,
      AppIntl.of(context)!.profile_number_registered_credits_program,
      AppIntl.of(context)!.profile_number_completed_courses_program,
      AppIntl.of(context)!.profile_number_failed_courses_program,
      AppIntl.of(context)!.profile_number_equivalent_courses_program,
      AppIntl.of(context)!.profile_status_program
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
                color: AppTheme.etsLightRed),
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
  } else {
    return const Column();
  }
}
