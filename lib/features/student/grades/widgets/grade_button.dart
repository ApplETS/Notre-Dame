// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';

class GradeButton extends StatelessWidget {
  final Course course;
  final bool showDiscovery;
  final Color? color;

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Settings manager
  final SettingsManager _settingsManager = locator<SettingsManager>();

  GradeButton(this.course, {this.color, this.showDiscovery = false});

  @override
  Widget build(BuildContext context) => Card(
        color: color,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            if (ModalRoute.of(context)!.settings.name ==
                    RouterPaths.dashboard ||
                await _settingsManager
                        .getBool(PreferencesFlag.discoveryStudentGrade) ==
                    true) {
              _navigationService.pushNamed(RouterPaths.gradeDetails,
                  arguments: course);
            }
          },
          child: showDiscovery
              ? _buildDiscoveryFeatureDescriptionWidget(
                  context, _buildGradeButton(context))
              : _buildGradeButton(context),
        ),
      );

  /// Build the grade string based on the available information. By default
  /// will return [grades_not_available].
  String gradeString(AppIntl intl) {
    if (course.grade != null) {
      return course.grade!;
    } else if (course.summary != null &&
        course.summary!.markOutOf > 0 &&
        !(course.inReviewPeriod && !(course.allReviewsCompleted ?? false))) {
      return intl.grades_grade_in_percentage(
          course.summary!.currentMarkInPercent.round());
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
                                    .bodyMedium!
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
                child: Text(gradeString(AppIntl.of(context)!),
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
