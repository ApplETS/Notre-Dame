// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/grades_details_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/base_scaffold.dart';

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Container(width: 100, height: 100, decoration: const BoxDecoration(color: Colors.green)),
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
                                  Text("85,3/100 (85 %)", style: TextStyle(color: Colors.red)),                                  
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
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Divider(color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  const Text("Sommaire", style: TextStyle(color: AppTheme.etsLightRed)),
                  getSummary("Médiane", "82,9"),
                  getSummary("Écart-type", "4,7"),
                  getSummary("Rang centile", "96"),
                ],
              ),
            ),
          ],
        )
      ),
    );

    Padding getSummary(String title, String grade) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(grade, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
}
