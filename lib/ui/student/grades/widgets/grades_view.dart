// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/student/grades/view_model/grades_viewmodel.dart';
import 'package:notredame/ui/student/grades/widgets/grade_button.dart';
import 'package:notredame/utils/loading.dart';

class GradesView extends StatefulWidget {
  const GradesView({super.key});

  @override
  State<GradesView> createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GradesViewModel>.reactive(
        viewModelBuilder: () => GradesViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) {
          return RefreshIndicator(
            onRefresh: () => model.refresh(),
            child: Stack(
              children: [
                // This widget is here to make this widget a Scrollable. Needed
                // by the RefreshIndicator
                ListView(),
                if (model.coursesBySession.isEmpty)
                  Center(
                      child: Text(AppIntl.of(context)!.grades_msg_no_grades,
                          textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge))
                else
                  ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0),
                    itemCount: model.coursesBySession.length,
                    itemBuilder: (BuildContext context, int index) => _buildSessionCourses(
                        index,
                        _sessionName(model.sessionOrder[index], AppIntl.of(context)!),
                        model.coursesBySession[model.sessionOrder[index]]!,
                        model),
                  ),
                if (model.isBusy) buildLoading() else const SizedBox()
              ],
            ),
          );
        });
  }

  /// Build a session which is the name of the session and one [GradeButton] for
  /// each [Course] in [courses]
  Widget _buildSessionCourses(int index, String sessionName, List<Course> courses, GradesViewModel model) => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  sessionName,
                  style: const TextStyle(
                    fontSize: 25,
                    color: AppPalette.etsLightRed,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.today, color: AppPalette.grey.darkGrey),
                  tooltip: AppIntl.of(context)!.grades_in_schedule(sessionName),
                  onPressed: () =>
                      _navigationService.pushNamed(RouterPaths.defaultSchedule, arguments: model.sessionOrder[index]),
                ),
              ],
            ),
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
        return "${intl.session_summer} ${shortName.substring(1)}";
      default:
        return intl.session_without;
    }
  }
}
