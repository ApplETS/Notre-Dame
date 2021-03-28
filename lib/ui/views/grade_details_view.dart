// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/grade_evaluation_tile.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/grades_details_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/grade_circular_progress.dart';

// OTHERS
class GradesDetailsView extends StatefulWidget {
  @override
  _GradesDetailsViewState createState() => _GradesDetailsViewState();
}

class _GradesDetailsViewState extends State<GradesDetailsView> {
  @override
  Widget build(BuildContext context) =>
    ViewModelBuilder<GradesDetailsViewModel>.reactive(
      viewModelBuilder: () => GradesDetailsViewModel(intl: AppIntl.of(context)),
      builder: (context, model, child) => BaseScaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: 
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width, maxHeight: 75),
                decoration: const BoxDecoration(color: AppTheme.primary,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text("COM110", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 3),
                      child: Text("Méthodes de communication", style: TextStyle(color: Colors.white)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 3),
                      child: Text("Groupe 02", style: TextStyle(color: Colors.white)),
                    ),
                  ]
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget> [
                    Row(
                      children: [
                        const GradeCircularProgress(0.85, 0.72, 1),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget> [
                                  Text("85,3/100 (85 %)", style: TextStyle(color: Colors.green)),                                
                                  Text("Votre note", style: TextStyle(color: Colors.green)),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget> [
                                    Text("85,3/100 (72 %)", style: TextStyle(color: Colors.red)),                                  
                                    Text("Moyenne", style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),                  
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget> [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        getHeadersSummary("Médiane"),
                        getNumberSummary("96"),
                        getHeadersSummary("Écart-type"),
                        getNumberSummary("4,3"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        getHeadersSummary("Rang-centile"),
                        getNumberSummary("55"),
                        getHeadersSummary("Crédits"),
                        getNumberSummary("4"),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: const <Widget>[
                  GradeEvaluationTile('Devoir 1', "10 %"),
                  GradeEvaluationTile('Final', "40 %"),
                  GradeEvaluationTile('Intra', "40 %"),
                  GradeEvaluationTile('Devoir 2', "10 %"),
                ],
              )
            ],
          ),
      ),
    );

    Padding getHeadersSummary(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
        child: Text(title, style: const TextStyle(color: Colors.grey)),
      );
    }

    Padding getNumberSummary(String number) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 5),
        child: Text(number, style: const TextStyle(color: Colors.black, fontSize: 18)),
      );
    }
}
