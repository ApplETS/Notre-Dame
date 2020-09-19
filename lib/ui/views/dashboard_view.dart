// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

import 'package:notredame/ui/utils/app_theme.dart';

// WIDGETS
import 'package:notredame/ui/widgets/bottom_bar.dart';
import 'package:notredame/core/models/cours.dart';
import 'package:notredame/core/models/trimester.dart';
import 'package:notredame/ui/widgets/trimester_widget.dart';
import 'package:notredame/ui/widgets/applets_widget.dart';

// GENERATED
import 'package:notredame/generated/l10n.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    Cours cours1 = Cours('Log121', 'log 121');
    cours1.finalGrade = 'A+';
    Cours cours2 = Cours('Log122', 'log 122');
    cours2.finalGrade = 'A';
    Cours cours3 = Cours('Log123', 'log 123');
    cours3.finalGrade = 'A-';
    Cours cours4 = Cours('Log124', 'log 124');
    cours4.finalGrade = 'B+';
    Cours cours5 = Cours('Log125', 'log 125');
    cours5.finalGrade = 'ND';
    Cours cours6 = Cours('Log126', 'log 126');
    cours6.finalGrade = 'ND';
    Cours cours7 = Cours('Log127', 'log 127');
    cours7.finalGrade = 'ND';
    Trimester uneSession = Trimester(AppIntl.of(context).grades_title);
    uneSession.addingCours(cours1);
    uneSession.addingCours(cours2);
    uneSession.addingCours(cours3);
    uneSession.addingCours(cours4);
    uneSession.addingCours(cours5);
    uneSession.addingCours(cours6);
    uneSession.addingCours(cours7);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(AppIntl.of(context).title_dashboard),
        ),
        body: Builder(
            builder: (BuildContext context) => SafeArea(
                  minimum: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                      child: Wrap(children: <Widget>[
                    Center(child: ApplETSWidget()),
                    Center(child: TrimesterWidget(uneSession)),
                  ])),
                )),
        bottomNavigationBar: BottomBar(BottomBar.dashboardView));
  }
}
