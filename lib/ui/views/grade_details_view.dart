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
        body: Container(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width, maxHeight: 75),
          decoration: const BoxDecoration(color: AppTheme.primary,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text("COM110", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0, top: 3),
                child: Text("Méthodes de communication", style: TextStyle(color: Colors.white)),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0, top: 3),
                child: Text("Groupe 02", style: TextStyle(color: Colors.white)),
              ),
            ]
          ),
        )
      ),
    );
}
