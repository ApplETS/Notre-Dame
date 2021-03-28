// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/grade_evaluation_tile.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/grades_details_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';

// OTHERS
class GradesDetailsView extends StatefulWidget {
  @override
  _GradesDetailsViewState createState() => _GradesDetailsViewState();
}

class _GradesDetailsViewState extends State<GradesDetailsView> {
  double top = 0.0;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<
          GradesDetailsViewModel>.reactive(
      viewModelBuilder: () => GradesDetailsViewModel(intl: AppIntl.of(context)),
      builder: (context, model, child) => BaseScaffold(
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  elevation: 0,
                  onStretchTrigger: () {
                    return Future<void>.value();
                  },
                  expandedHeight: 80.0,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      top = constraints.biggest.height;
                      return FlexibleSpaceBar(
                        centerTitle: true,
                        titlePadding: EdgeInsetsDirectional.only(
                          start: top < 120 ? 60 : 15,
                          top: top < 120 ? 5 : 15,
                          bottom: top < 120 ? 15 : 1,
                        ),
                        title: Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: Text(
                            "COM110",
                            style: TextStyle(fontSize: top < 120 ? 20 : 15),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                          maxHeight: 40),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppTheme.etsLightRed
                            : const Color(0xff222222),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            getClassInformation("Méthodes de communication"),
                            getClassInformation("Groupe 02"),
                          ]),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const GradeCircularProgress(0.85, 0.72, 1),
                              Padding(
                                padding: const EdgeInsets.only(left: 55.0),
                                child: Column(
                                  children: [
                                    getGrade("85,3/100 (85 %)", "Votre note",
                                        Colors.green),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: getGrade("75,2/100 (75 %)",
                                          "Moyenne", AppTheme.etsLightRed),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        getHeadersSummary("Médiane", "83,2"),
                        getHeadersSummary("Écart-type", "4,62"),
                        getHeadersSummary("Rang centile", "85"),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        GradeEvaluationTile('Devoir 1', "10 %", 0.95, 0.75),
                        GradeEvaluationTile('Final', "40 %", 0.72, 0.89),
                        GradeEvaluationTile('Intra', "40 %", 0.36, 0.55),
                        GradeEvaluationTile('Devoir 2', "10 %", 0.15, 0.68),
                        GradeEvaluationTile('Devoir 3', "10 %", 0.96, 0.48),
                        GradeEvaluationTile('Quiz 1', "10 %", 0.89, 0.98),
                        GradeEvaluationTile('Quiz 2', "10 %", 0.67, 0.36),
                      ],
                    ),
                  ]),
                ),
              ],
            ),
          ));

  Align getClassInformation(String info) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text(info, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Column getGrade(String grade, String recipient, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          grade,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(recipient, style: TextStyle(color: color)),
      ],
    );
  }

  Column getHeadersSummary(String title, String number) {
    return Column(
      children: [
        Container(
          height: 90,
          width: MediaQuery.of(context).size.width / 3.2,
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                  child: Text(
                    title,
                  ),
                ),
                Text(
                  number,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Padding getNumberSummary(String number) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 5),
      child: Text(number,
          style: const TextStyle(color: Colors.black, fontSize: 18)),
    );
  }
}
