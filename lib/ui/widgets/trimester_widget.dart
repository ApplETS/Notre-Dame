// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/core/model/cours.dart';
import 'package:notredame/core/model/trimester.dart';
import 'package:notredame/ui/utils/app_theme.dart';

import 'Grade_Button.dart';

class TrimesterWidget extends StatelessWidget {
  List<Cours> _coursParSession;
  String _title;

  TrimesterWidget(Trimester trimester) {
    _coursParSession = trimester.coursParSession;
    _title = trimester.trimesterTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_title,
            style: const TextStyle(
              fontSize: 25,
              color: AppTheme.etsLightRed,
            )),
        Wrap(
          spacing: 8.0, // gap between adjacent chips
          runSpacing: 16.0,
          children: _settingGradesButtons(),
        ),
      ],
    );
  }

  List<GradeButton> _settingGradesButtons() {
    List<GradeButton> gradeButtons = <GradeButton>[];
    for (Cours cours in _coursParSession) {
      gradeButtons.add(GradeButton(cours.code, cours.finalGrade));
    }
    return gradeButtons;
  }
}
