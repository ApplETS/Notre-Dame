// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/core/model/cours.dart';
import 'package:notredame/core/model/trimester.dart';
import 'package:notredame/ui/widgets/grade_button.dart';
import 'package:notredame/ui/widgets/trimester_widget.dart';

class LoginView extends StatelessWidget {
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
    Trimester uneSession = Trimester('Automne 2020');
    uneSession.addingCours(cours1);
    uneSession.addingCours(cours2);
    uneSession.addingCours(cours3);
    uneSession.addingCours(cours4);
    uneSession.addingCours(cours5);
    uneSession.addingCours(cours6);
    uneSession.addingCours(cours7);
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: TrimesterWidget(uneSession),
      ),
    ) //Center(child: Text("Welcome to the new ÉTS Mobile!")),
        );
  }
}
