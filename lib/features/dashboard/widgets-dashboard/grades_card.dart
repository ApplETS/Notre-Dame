// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';
import 'package:notredame/features/student/grades/widgets/grade_button.dart';
import 'package:notredame/utils/app_theme.dart';

class GradesCard extends StatelessWidget {
  final DashboardViewModel model;
  final PreferencesFlag flag;
  final VoidCallback dismissCard;

  const GradesCard({
    required this.model,
    required this.flag,
    required this.dismissCard,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = NavigationService();

    return DismissibleCard(
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) {
        dismissCard();
      },
      isBusy: model.busy(model.courses),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: GestureDetector(
                  onTap: () => navigationService
                      .pushNamedAndRemoveUntil(RouterPaths.student),
                  child: Text(AppIntl.of(context)!.grades_title,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ),
            if (model.courses.isEmpty)
              SizedBox(
                height: 100,
                child: Center(
                    child: Text(AppIntl.of(context)!
                        .grades_msg_no_grades
                        .split("\n")
                        .first)),
              )
            else
              Container(
                padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
                child: Wrap(
                  children: model.courses
                      .map((course) => GradeButton(course,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? AppTheme.lightThemeBackground
                                  : AppTheme.darkThemeBackground))
                      .toList(),
                ),
              )
          ]),
    );
  }
}
