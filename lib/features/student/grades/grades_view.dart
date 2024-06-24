// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/student/grades/grades_viewmodel.dart';
import 'package:notredame/features/student/grades/widgets/grade_button.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/loading.dart';
import 'package:notredame/utils/locator.dart';

class GradesView extends StatefulWidget {
  @override
  _GradesViewState createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      GradesViewModel.startDiscovery(context);
    });

    _analyticsService.logEvent("GradesView", "Opened");
  }

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
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge))
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: AnimationLimiter(
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: model.coursesBySession.length,
                          itemBuilder: (BuildContext context, int index) =>
                              AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 750),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _buildSessionCourses(
                                        index,
                                        _sessionName(model.sessionOrder[index],
                                            AppIntl.of(context)!),
                                        model.coursesBySession[
                                            model.sessionOrder[index]]!,
                                        model),
                                  ),
                                ),
                              )),
                    ),
                  ),
                if (model.isBusy)
                  buildLoading(isInteractionLimitedWhileLoading: false)
                else
                  const SizedBox()
              ],
            ),
          );
        });
  }

  /// Build a session which is the name of the session and one [GradeButton] for
  /// each [Course] in [courses]
  Widget _buildSessionCourses(int index, String sessionName,
          List<Course> courses, GradesViewModel model) =>
      Padding(
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
                    color: AppTheme.etsLightRed,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.today, color: AppTheme.etsDarkGrey),
                  onPressed: () => _navigationService.pushNamed(
                      RouterPaths.defaultSchedule,
                      arguments: model.sessionOrder[index]),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Wrap(
              children: courses
                  .map((course) =>
                      GradeButton(course, showDiscovery: index == 0))
                  .toList(),
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
