// GradesView.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/student/grades/widget-grade-view/empty_grades_message.dart';
import 'package:notredame/features/student/grades/widget-grade-view/grade_list.dart';
import 'package:stacked/stacked.dart';

import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/student/grades/grades_viewmodel.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/loading.dart';

class GradesView extends StatefulWidget {
  @override
  _GradesViewState createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

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
                ListView(),
                if (model.coursesBySession.isEmpty)
                  EmptyGradesMessage()
                else
                  GradeList(model: model),
                if (model.isBusy)
                  buildLoading(isInteractionLimitedWhileLoading: false)
                else
                  const SizedBox()
              ],
            ),
          );
        });
  }
}
