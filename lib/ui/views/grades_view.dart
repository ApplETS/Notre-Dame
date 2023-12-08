// Flutter imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';
import 'package:notredame/ui/widgets/dismissible_card.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/viewmodels/grades_viewmodel.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/utils/loading.dart';
import 'package:notredame/ui/widgets/grade_button.dart';

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
        viewModelBuilder: () => GradesViewModel(intl: AppIntl.of(context)),
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
                      child: Text(AppIntl.of(context).grades_msg_no_grades,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6))
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
                                            AppIntl.of(context)),
                                        model.coursesBySession[
                                            model.sessionOrder[index]],
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
            if (model.remoteConfigService.gradesMessageActive && index == 0)
              _buildMessageBroadcastCard(model),
            Text(sessionName,
                style: const TextStyle(
                  fontSize: 25,
                  color: AppTheme.etsLightRed,
                )),
            const SizedBox(height: 16.0),
            Wrap(
              children: courses
                  .map((course) => index == 0
                      ? GradeButton(course, showDiscovery: true)
                      : GradeButton(course, showDiscovery: false))
                  .toList(),
            ),
          ],
        ),
      );

  Widget _buildMessageBroadcastCard(GradesViewModel model) {
    final broadcastMsgColor = Color(int.parse(model.broadcastColor));
    final broadcastMsgType = model.broadcastType;
    final broadcastMsgUrl = model.broadcastUrl;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DismissibleCard(
          key: UniqueKey(),
          onDismissed: (DismissDirection direction) {},
          isBusy: model.busy(model.broadcastMessage),
          cardColor: broadcastMsgColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // title row
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(model.broadcastTitle,
                          style: Theme.of(context).primaryTextTheme.headline6),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      child:
                          getBroadcastIcon(broadcastMsgType, broadcastMsgUrl),
                    ),
                  ),
                ],
              ),
              // main text
              AutoSizeText(model.broadcastMessage ?? "",
                  style: Theme.of(context).primaryTextTheme.bodyText2)
            ]),
          )),
    );
  }

  Widget getBroadcastIcon(String type, String url) {
    switch (type) {
      case "warning":
        return const Icon(
          Icons.warning_rounded,
          color: AppTheme.lightThemeBackground,
          size: 36.0,
        );
      case "alert":
        return const Icon(
          Icons.error,
          color: AppTheme.lightThemeBackground,
          size: 36.0,
        );
      case "link":
        return IconButton(
          onPressed: () {
            DashboardViewModel.launchBroadcastUrl(url);
          },
          icon: const Icon(
            Icons.open_in_new,
            color: AppTheme.lightThemeBackground,
            size: 30.0,
          ),
        );
    }
    return const Icon(
      Icons.campaign,
      color: AppTheme.lightThemeBackground,
      size: 36.0,
    );
  }

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
