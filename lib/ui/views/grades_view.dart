// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/loading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:stacked/stacked.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// MODELS
import 'package:notredame/core/models/course.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/grades_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_button.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradesView extends StatefulWidget {
  @override
  _GradesViewState createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GradesViewModel>.reactive(
      viewModelBuilder: () => GradesViewModel(intl: AppIntl.of(context)),
      builder: (context, model, child) => RefreshIndicator(
        onRefresh: () async {
          if (await model.refresh()) {
            showToast(AppIntl.of(context).error);
          }
        },
        child: Stack(
          children: [
            // This widget is here to make this widget a Scrollable. Needed
            // by the RefreshIndicator
            ListView(),
            if (model.coursesBySession.isEmpty)
              Center(
                  child: TextButton(
                      child: const Text('Afficher note...'),
                      onPressed: () {
                        model.navigationService.pushNamed(RouterPaths.grade_details);
                      }))
            else
              ListView.builder(
                  itemCount: model.coursesBySession.length,
                  itemBuilder: (BuildContext context, int index) => _buildSessionCourses(
                      _sessionName(model.sessionOrder[index], AppIntl.of(context)),
                      model.coursesBySession[model.sessionOrder[index]])),
            if (model.isBusy) buildLoading(isInteractionLimitedWhileLoading: false) else const SizedBox()
          ],
        ),
      ),
    );
  }

  /// Build a session which is the name of the session and one [GradeButton] for
  /// each [Course] in [courses]
  Widget _buildSessionCourses(String sessionName, List<Course> courses) => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(sessionName,
                style: const TextStyle(
                  fontSize: 25,
                  color: AppTheme.etsDarkRed,
                )),
            const SizedBox(height: 16.0),
            Wrap(
              children: courses.map((course) => GradeButton(course)).toList(),
            ),
          ],
        ),
      );

  /// Build the complete name of the session for the user local.
  String _sessionName(String shortName, AppIntl intl) {
    switch (shortName[0]) {
      case 'H':
        return "${intl.session_winter} ${shortName.substring(1)}";
      case 'A':
        return "${intl.session_fall} ${shortName.substring(1)}";
      case 'É':
      default:
        return "${intl.session_summer} ${shortName.substring(1)}";
    }
  }
}
