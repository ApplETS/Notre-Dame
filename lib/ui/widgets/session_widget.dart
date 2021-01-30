// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
//models
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/session.dart';
// CONSTANT
import 'package:notredame/ui/utils/app_theme.dart';
// widgets
import 'Grade_Button.dart';

class SessionWidget extends StatelessWidget {
  final List<Course> _coursParSession;
  final String _title;

  SessionWidget(Session session, List<Course> courses)
      : _coursParSession = courses,
        _title = session.name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
          child: Text(_title,
              style: const TextStyle(
                fontSize: 25,
                color: AppTheme.etsBlack,
              )),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 16.0,
          children: _settingGradesButtons(),
        ),
      ],
    );
  }

  List<GradeButton> _settingGradesButtons() {
    final List<GradeButton> gradeButtons = <GradeButton>[];
    for (final Course cours in _coursParSession) {
      gradeButtons
          .add(GradeButton(codeTxt: cours.acronym, gradeTxt: cours.grade));
    }
    return gradeButtons;
  }
}
