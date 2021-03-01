// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// MODELS
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/session.dart';

// WIDGETS
import 'package:notredame/ui/widgets/session_widget.dart';


class GradesView extends StatefulWidget {
  @override
  _GradesViewState createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  @override
  Widget build(BuildContext context) {
    final Course cours1 = Course(
        acronym: 'LOG410',
        session: 'H2021',
        group: '02',
        numberOfCredits: 3,
        programCode: '7365',
        grade: 'A+',
        title: 'Analyse de besoins et spécifications');
    final Course cours3 = Course(
        acronym: 'LOG410',
        session: 'H2021',
        group: '02',
        numberOfCredits: 3,
        programCode: '7365',
        grade: 'B',
        title: 'Analyse de besoins et spécifications');
    final Course cours4 = Course(
        acronym: 'LOG410',
        session: 'H2021',
        group: '02',
        numberOfCredits: 3,
        programCode: '7365',
        grade: 'H/B-',
        title: 'Analyse de besoins et spécifications');
    final Course cours5 = Course(
        acronym: 'LOG410',
        session: 'H2021',
        group: '02',
        numberOfCredits: 3,
        programCode: '7365',
        grade: 'N/A',
        title: 'Analyse de besoins et spécifications');
    final Course cours6 = Course(
        acronym: 'LOG410',
        session: 'H2021',
        group: '02',
        numberOfCredits: 3,
        programCode: '7365',
        grade: 'ND',
        title: 'Analyse de besoins et spécifications');
    final Course cours7 = Course(
        acronym: 'LOG410',
        session: 'H2021',
        group: '02',
        numberOfCredits: 3,
        programCode: '7365',
        grade: 'A+',
        title: 'Analyse de besoins et spécifications');

    final Session uneSession = Session(
        shortName: 'H2018',
        name: 'Hiver 2018',
        startDate: DateTime(2018, 1, 4),
        endDate: DateTime(2018, 4, 23),
        endDateCourses: DateTime(2018, 4, 11),
        startDateRegistration: DateTime(2017, 10, 30),
        deadlineRegistration: DateTime(2017, 11, 14),
        startDateCancellationWithRefund: DateTime(2018, 1, 4),
        deadlineCancellationWithRefund: DateTime(2018, 1, 17),
        deadlineCancellationWithRefundNewStudent: DateTime(2018, 1, 31),
        startDateCancellationWithoutRefundNewStudent: DateTime(2018, 2),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2018, 3, 14),
        deadlineCancellationASEQ: DateTime(2018, 1, 31));

    return Wrap(children: <Widget>[
      Center(
          child: SessionWidget(uneSession,
              [cours1, cours3, cours3, cours4, cours5, cours6, cours7])),
    ]);
  }
}
