// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/constants/update_code.dart';
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';
import 'package:notredame/features/dashboard/progress_bar_text_options.dart';
import 'package:notredame/features/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/features/dashboard/widgets/haptics_container.dart';
import 'package:notredame/features/student/grades/widgets/grade_button.dart';
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/loading.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/utils.dart';

class DashboardView extends StatefulWidget {
  final UpdateCode updateCode;
  const DashboardView({super.key, required this.updateCode});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  Text? progressBarText;
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  static const String tag = "DashboardView";

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      DashboardViewModel.startDiscovery(context);
      DashboardViewModel.promptUpdate(context, widget.updateCode);
    });
    DashboardViewModel.launchInAppReview();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
        viewModelBuilder: () => DashboardViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) {
          return BaseScaffold(
              isInteractionLimitedWhileLoading: false,
              appBar: AppBar(
                  title: Text(AppIntl.of(context)!.title_dashboard),
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  actions: [
                    _buildDiscoveryFeatureDescriptionWidget(
                        context, Icons.restore, model),
                  ]),
              body: model.cards == null
                  ? buildLoading()
                  : RefreshIndicator(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(canvasColor: Colors.transparent),
                        child: ReorderableListView(
                          onReorder: (oldIndex, newIndex) =>
                              onReorder(model, oldIndex, newIndex),
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                          children: _buildCards(model),
                          proxyDecorator: (child, _, __) {
                            return HapticsContainer(child: child);
                          },
                        ),
                      ),
                      onRefresh: () => model.loadDataAndUpdateWidget(),
                    ));
        });
  }

  List<Widget> _buildCards(DashboardViewModel model) {
    final List<Widget> cards = List.empty(growable: true);

    // always try to build broadcast cart so the user doesn't miss out on
    // important info if they dismissed it previously

    for (final PreferencesFlag element in model.cardsToDisplay ?? []) {
      switch (element) {
        case PreferencesFlag.broadcastCard:
          if (model.remoteConfigService.dashboardMessageActive) {
            cards.add(_buildMessageBroadcastCard(model, element));
          }
        case PreferencesFlag.aboutUsCard:
          cards.add(_buildAboutUsCard(model, element));
        case PreferencesFlag.scheduleCard:
          cards.add(_buildScheduleCard(model, element));
        case PreferencesFlag.progressBarCard:
          cards.add(_buildProgressBarCard(model, element));
        case PreferencesFlag.gradesCard:
          cards.add(_buildGradesCards(model, element));

        default:
      }

      setText(model);
    }

    return cards;
  }

  Widget _buildAboutUsCard(DashboardViewModel model, PreferencesFlag flag) =>
      DismissibleCard(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) {
          dismissCard(model, flag);
        },
        cardColor: AppTheme.appletsPurple,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: Text(AppIntl.of(context)!.card_applets_title,
                    style: Theme.of(context).primaryTextTheme.titleLarge),
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
                child: Text(AppIntl.of(context)!.card_applets_text,
                    style: Theme.of(context).primaryTextTheme.bodyMedium),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Wrap(spacing: 15.0, children: [
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Facebook clicked");
                        Utils.launchURL(
                            Urls.clubFacebook, AppIntl.of(context)!);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.facebook,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Instagram clicked");
                        Utils.launchURL(
                            Urls.clubInstagram, AppIntl.of(context)!);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.instagram,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Github clicked");
                        Utils.launchURL(Urls.clubGithub, AppIntl.of(context)!);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.github,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Email clicked");
                        Utils.launchURL(Urls.clubEmail, AppIntl.of(context)!);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.envelope,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Discord clicked");
                        Utils.launchURL(Urls.clubDiscord, AppIntl.of(context)!);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.discord,
                        color: Colors.white,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ]),
      );

  Widget _buildProgressBarCard(
          DashboardViewModel model, PreferencesFlag flag) =>
      DismissibleCard(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) {
          dismissCard(model, flag);
        },
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: Text(AppIntl.of(context)!.progress_bar_title,
                    style: Theme.of(context).textTheme.titleLarge),
              )),
          if (model.busy(model.progress) || model.progress >= 0.0)
            Skeletonizer(
              enabled: model.busy(model.progress),
              ignoreContainers: true,
              effect: const ShimmerEffect(),
              child: Stack(children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: GestureDetector(
                      onTap: () => setState(
                        () => setState(() {
                          model.changeProgressBarText();
                          setText(model);
                        }),
                      ),
                      child: LinearProgressIndicator(
                        value: model.progress,
                        minHeight: 30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.gradeGoodMax),
                        backgroundColor: AppTheme.etsDarkGrey,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    model.changeProgressBarText();
                    setText(model);
                  }),
                  child: Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: progressBarText ??
                          Text(
                            AppIntl.of(context)!.progress_bar_message(
                                model.sessionDays[0], model.sessionDays[1]),
                            style: const TextStyle(color: Colors.white),
                          ),
                    ),
                  ),
                ),
              ]),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(AppIntl.of(context)!.session_without),
              ),
            ),
        ]),
      );

  void setText(DashboardViewModel model) {
    if (model.sessionDays[0] == 0 || model.sessionDays[1] == 0) {
      return;
    }

    if (model.currentProgressBarText ==
        ProgressBarText.daysElapsedWithTotalDays) {
      progressBarText = Text(
        AppIntl.of(context)!
            .progress_bar_message(model.sessionDays[0], model.sessionDays[1]),
        style: const TextStyle(color: Colors.white),
      );
    } else if (model.currentProgressBarText == ProgressBarText.percentage) {
      progressBarText = Text(
        AppIntl.of(context)!.progress_bar_message_percentage(
            ((model.sessionDays[0] / model.sessionDays[1]) * 100).round()),
        style: const TextStyle(color: Colors.white),
      );
    } else {
      progressBarText = Text(
        AppIntl.of(context)!.progress_bar_message_remaining_days(
            model.sessionDays[1] - model.sessionDays[0]),
        style: const TextStyle(color: Colors.white),
      );
    }
  }

  Widget _buildScheduleCard(DashboardViewModel model, PreferencesFlag flag) {
    var title = AppIntl.of(context)!.title_schedule;
    if (model.todayDateEvents.isEmpty && model.tomorrowDateEvents.isNotEmpty) {
      title = title + AppIntl.of(context)!.card_schedule_tomorrow;
    }
    final bool isLoading = model.busy(model.todayDateEvents) || model.busy(model.tomorrowDateEvents);
    return DismissibleCard(
      onDismissed: (DismissDirection direction) {
        dismissCard(model, flag);
      },
      key: UniqueKey(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: GestureDetector(
                  onTap: () => _navigationService
                      .pushNamedAndRemoveUntil(RouterPaths.schedule),
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              )),
          if (isLoading)
            Skeletonizer(
                child: _buildEventList([
                  CourseActivity(
                      courseGroup: "APP375-99",
                      courseName: "Développement mobile (ÉTSMobile)",
                      activityName: '',
                      activityDescription: '5 à 7',
                      activityLocation: '100 Génies',
                      startDateTime: DateTime.now(),
                      endDateTime:  DateTime.now()
                  )]))
          else if (model.todayDateEvents.isEmpty)
             if (model.tomorrowDateEvents.isEmpty)
              SizedBox(
                  height: 100,
                  child: Center(
                      child: Text(AppIntl.of(context)!.schedule_no_event)))
            else
              _buildEventList(model.tomorrowDateEvents)
          else
            _buildEventList(model.todayDateEvents)
        ]),
      ),
    );
  }

  /// Build the list of the events for the selected day.
  Widget _buildEventList(List<dynamic> events) {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        itemBuilder: (_, index) =>
            CourseActivityTile(events[index] as CourseActivity),
        separatorBuilder: (_, index) => (index < events.length)
            ? const Divider(thickness: 1, indent: 30, endIndent: 30)
            : const SizedBox(),
        itemCount: events.length);
  }

  Widget _buildGradesCards(DashboardViewModel model, PreferencesFlag flag) =>
      DismissibleCard(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) {
          dismissCard(model, flag);
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                  child: GestureDetector(
                    onTap: () => _navigationService
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
                Skeletonizer(
                  enabled: model.busy(model.courses),
                  child: Container(
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
                  ),
                )
            ]),
      );

  Widget _buildMessageBroadcastCard(
      DashboardViewModel model, PreferencesFlag flag) {
    final broadcastMsgColor = Color(int.parse(model.broadcastColor));
    final broadcastMsgType = model.broadcastType;
    final broadcastMsgUrl = model.broadcastUrl;
    return DismissibleCard(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) {
          dismissCard(model, flag);
        },
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
                        style: Theme.of(context).primaryTextTheme.titleLarge),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    child: getBroadcastIcon(broadcastMsgType, broadcastMsgUrl),
                  ),
                ),
              ],
            ),
            // main text
            AutoSizeText(model.broadcastMessage,
                style: Theme.of(context).primaryTextTheme.bodyMedium)
          ]),
        ));
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

  void dismissCard(DashboardViewModel model, PreferencesFlag flag) {
    model.hideCard(flag);
  }

  void onReorder(DashboardViewModel model, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      // ignore: parameter_assignments
      newIndex -= 1;
    }

    // Should not happen becase dismiss card will not be called if the card is null.
    if (model.cards == null) {
      _analyticsService.logError(tag, "Cards list is null");
      throw Exception("Cards is null");
    }

    final PreferencesFlag elementMoved = model.cards!.keys
        .firstWhere((element) => model.cards![element] == oldIndex);

    model.setOrder(elementMoved, newIndex);
  }

  DescribedFeatureOverlay _buildDiscoveryFeatureDescriptionWidget(
      BuildContext context, IconData icon, DashboardViewModel model) {
    final discovery = getDiscoveryByFeatureId(context,
        DiscoveryGroupIds.bottomBar, DiscoveryIds.bottomBarDashboardRestore);

    return DescribedFeatureOverlay(
      overflowMode: OverflowMode.wrapBackground,
      contentLocation: ContentLocation.below,
      featureId: discovery.featureId,
      title: Text(discovery.title, textAlign: TextAlign.justify),
      description: discovery.details,
      backgroundColor: AppTheme.appletsDarkPurple,
      tapTarget: Icon(icon, color: AppTheme.etsBlack),
      onComplete: () => model.discoveryCompleted(),
      pulseDuration: const Duration(seconds: 5),
      child: IconButton(
        icon: Icon(icon),
        onPressed: model.setAllCardsVisible,
      ),
    );
  }
}
