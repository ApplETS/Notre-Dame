// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/core/models/program.dart';
import 'package:stacked/stacked.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/profile_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/student_program.dart';

// OTHER
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ProfileViewModel>.reactive(
        viewModelBuilder: () => ProfileViewModel(),
        builder: (context, model, child) => Scaffold(
          body: ListView(children: [
            ListTile(
              title: Text(
                AppIntl.of(context).profile_student_status_title,
                style: const TextStyle(color: AppTheme.etsLightRed),
              ),
            ),
            ListTile(
              title: Text(AppIntl.of(context).profile_balance),
              trailing: Text(model.profileStudent.balance),
            ),
            const Divider(
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            ListTile(
              title: Text(
                AppIntl.of(context).profile_personal_information_title,
                style: const TextStyle(color: AppTheme.etsLightRed),
              ),
            ),
            ListTile(
              title: Text(AppIntl.of(context).profile_first_name),
              trailing: Text(model.profileStudent.firstName),
            ),
            ListTile(
              title: Text(AppIntl.of(context).profile_last_name),
              trailing: Text(model.profileStudent.lastName),
            ),
            ListTile(
                title: Text(AppIntl.of(context).profile_permanent_code),
                trailing: Text(model.profileStudent.permanentCode)),
            ListTile(
                title: Text(AppIntl.of(context).login_prompt_universal_code),
                trailing: Text(model.universalAccessCode)),
            FutureBuilder(
              future: model.getProgramsList(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    physics: const ScrollPhysics(),
                    itemCount: snapshot.data.length as int,
                    itemBuilder: (BuildContext context, int index) {
                      return StudentProgram(snapshot.data[index] as Program);
                    },
                  );
                }
              },
            ),
          ]),
        ),
      );
}
