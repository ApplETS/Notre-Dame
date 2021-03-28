// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';

class GradeEvaluationTile extends StatelessWidget {
  final String title;
  final String weight;

  const GradeEvaluationTile(this.title, this.weight);

  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData().copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
        leading: const GradeCircularProgress(0.85, 0.72, 0.80),
        title: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: const TextStyle(fontSize: 15)),
              Text('Pondération: $weight', style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
        trailing: Transform.rotate(angle: 180 * 3.14 / 360, child: const IconButton(icon: Icon(Icons.arrow_forward_ios, color: AppTheme.etsLightRed, size: 20,), onPressed: null,),),
        children: <Widget>[
          evaluationsSummary(context)
        ],
      )
  );

    Widget evaluationsSummary(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 8),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.91,
          child: Column(
            children: [
              getSummary("Note", "82,9"),
              getSummary("Moyenne", "4,7"),
              getSummary("Médianne", "4,2"),
              getSummary("Écart-type", "0,6"),
              getSummary("Rang centile", "79"),
              getSummary("Rang centile", "18 septembre 2020"),
            ],
          )
        ),
      );
    }

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
