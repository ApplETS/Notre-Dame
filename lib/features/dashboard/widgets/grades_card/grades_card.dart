// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/student/grades/widgets/grade_button.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/dashboard/widgets/grades_card/grades_card_viewmodel.dart';

class GradesCard extends StatelessWidget {
  final NavigationService navigationService = locator<NavigationService>();
  final VoidCallback onDismissed;

  GradesCard({
    required this.onDismissed,
    required super.key,
  });

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<GradesCardViewModel>.reactive(
        viewModelBuilder: () => GradesCardViewModel(),
        builder: (context, model, child) => DismissibleCard(
          key: UniqueKey(),
          onDismissed: (DismissDirection direction) => onDismissed(),
          isBusy: model.isBusy,
          child: GestureDetector(
            onTap: () => navigationService
                .pushNamedAndRemoveUntil(RouterPaths.student),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                      child: Text(AppIntl.of(context)!.grades_title,
                            style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ),
                  if (model.data == null || model.data!.isEmpty)
                    buildNoGradesContent(context)
                  else
                    buildGradesButton(model, context)
                ]),
          ),
        ),
      );

  Container buildGradesButton(GradesCardViewModel model, BuildContext context) =>
    Container(
      padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
      child: Wrap(
        children: model.data!
            .map((course) => GradeButton(course,
            color:
            Theme.of(context).brightness == Brightness.light
                ? AppTheme.lightThemeBackground
                : AppTheme.darkThemeBackground))
            .toList(),
      ),
    );

  SizedBox buildNoGradesContent(BuildContext context) =>
    SizedBox(
      height: 100,
      child: Center(
          child: Text(AppIntl.of(context)!
              .grades_msg_no_grades
              .split("\n")
              .first)),
    );

}
