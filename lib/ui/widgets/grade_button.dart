// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/constants/discovery_ids.dart';

// MODEL
import 'package:notredame/core/models/course.dart';

//OTHER
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/locator.dart';

// CONSTANT
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/utils/discovery_components.dart';

class GradeButton extends StatelessWidget {
  final Course course;
  final bool showDiscovery;

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  GradeButton(this.course, {this.showDiscovery});

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: () => _navigationService.pushNamed(RouterPaths.gradeDetails,
              arguments: course),
          child: showDiscovery
              ? _buildDiscoveryFeatureDescriptionWidget(
                  context, _buildGradeButton(context))
              : _buildGradeButton(context),
        ),
      );

  /// Build the grade string based on the available information. By default
  /// will return [grades_not_available].
  String gradeString(AppIntl intl) {
    if (course.grade == null &&
        course.summary != null &&
        course.summary.markOutOf > 0) {
      return intl.grades_grade_in_percentage(
          course.summary.currentMarkInPercent.round());
    } else if (course.grade != null) {
      return course.grade;
    }

    return intl.grades_not_available;
  }

  SizedBox _buildGradeButton(BuildContext context) {
    return SizedBox(
      height: 68,
      width: 68,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Hero(
                  tag: 'course_acronym_${course.acronym}_${course.session}',
                  child: Material(
                    child: DecoratedBox(
                        decoration: const BoxDecoration(
                            color: AppTheme.etsLightRed,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(2.5),
                                topRight: Radius.circular(2.5))),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                course.acronym,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        )),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
                child: Text(gradeString(AppIntl.of(context)),
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppTheme.etsDarkGrey
                          : AppTheme.etsLightGrey,
                    ))),
          )
        ],
      ),
    );
  }

  DescribedFeatureOverlay _buildDiscoveryFeatureDescriptionWidget(
      BuildContext context, Widget gradeButton) {
    final discovery = getDiscoveryByFeatureId(context,
        DiscoveryGroupIds.pageStudent, DiscoveryIds.detailsStudentGradeButton);

    return DescribedFeatureOverlay(
        overflowMode: OverflowMode.wrapBackground,
        contentLocation: ContentLocation.below,
        featureId: discovery.featureId,
        title: Text(discovery.title, textAlign: TextAlign.justify),
        description: discovery.details,
        backgroundColor: AppTheme.appletsDarkPurple,
        tapTarget: gradeButton,
        pulseDuration: const Duration(seconds: 5),
        child: gradeButton);
  }
}
