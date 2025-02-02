// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notredame/theme/app_palette.dart';
import 'package:notredame/theme/app_theme.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';
import 'package:notredame/features/dashboard/progress_bar_text_options.dart';
import 'package:notredame/features/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/features/dashboard/widgets/haptics_container.dart';
import 'package:notredame/features/student/grades/widgets/grade_button.dart';
import 'package:notredame/utils/loading.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  Text? progressBarText;
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  static const String tag = "DashboardView";

  @override
  void initState() {
    super.initState();
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
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: () => model.setAllCardsVisible(),
                    )
                  ],
                  automaticallyImplyLeading: false),
              body: model.cards == null
                  ? buildLoading()
                  : RefreshIndicator(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(canvasColor: Colors.transparent),
                        child: ReorderableListView(
                          header:
                              model.remoteConfigService.dashboardMessageActive
                                  ? _buildMessageBroadcastCard(model)
                                  : null,
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
        cardColor: AppPalette.appletsPurple,
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
                        _launchUrlService.launchInBrowser(Urls.clubFacebook);
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.facebook,
                        color: AppPalette.grey.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Instagram clicked");
                        _launchUrlService.launchInBrowser(Urls.clubInstagram);
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.instagram,
                        color: AppPalette.grey.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Github clicked");
                        _launchUrlService.launchInBrowser(Urls.clubGithub);
                        },
                      icon: FaIcon(
                        FontAwesomeIcons.github,
                        color: AppPalette.grey.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Email clicked");
                        _launchUrlService.writeEmail(Urls.clubEmail, "");
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.envelope,
                        color: AppPalette.grey.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Discord clicked");
                        _launchUrlService.launchInBrowser(Urls.clubDiscord);
                        },
                      icon: FaIcon(
                        FontAwesomeIcons.discord,
                        color: AppPalette.grey.white,
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
                            AppPalette.gradeGoodMax),
                        backgroundColor: AppPalette.grey.darkGrey,
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
                            style: TextStyle(color: AppPalette.grey.white),
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
        style: TextStyle(color: AppPalette.grey.white),
      );
    } else if (model.currentProgressBarText == ProgressBarText.percentage) {
      progressBarText = Text(
        AppIntl.of(context)!.progress_bar_message_percentage(
            ((model.sessionDays[0] / model.sessionDays[1]) * 100).round()),
        style: TextStyle(color: AppPalette.grey.white),
      );
    } else {
      progressBarText = Text(
        AppIntl.of(context)!.progress_bar_message_remaining_days(
            model.sessionDays[1] - model.sessionDays[0]),
        style: TextStyle(color: AppPalette.grey.white),
      );
    }
  }

  Widget _buildScheduleCard(DashboardViewModel model, PreferencesFlag flag) {
    var title = AppIntl.of(context)!.title_schedule;
    if (model.todayDateEvents.isEmpty && model.tomorrowDateEvents.isNotEmpty) {
      title += AppIntl.of(context)!.card_schedule_tomorrow;
    }
    final bool isLoading = model.busy(model.todayDateEvents) ||
        model.busy(model.tomorrowDateEvents);

    late List<CourseActivity>? courseActivities;
    if (isLoading) {
      // User will not see this.
      // It serves the purpuse of creating text in the skeleton and make it look closer to the real schedule.
      courseActivities = [
        CourseActivity(
            courseGroup: "APP375-99",
            courseName: "Développement mobile (ÉTSMobile)",
            activityName: '',
            activityDescription: '5 à 7',
            activityLocation: '100 Génies',
            startDateTime: DateTime.now(),
            endDateTime: DateTime.now())
      ];
    } else if (model.todayDateEvents.isEmpty) {
      if (model.tomorrowDateEvents.isEmpty) {
        courseActivities = null;
      } else {
        courseActivities = model.tomorrowDateEvents;
      }
    } else {
      courseActivities = model.todayDateEvents;
    }

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
          if (courseActivities != null)
            Skeletonizer(
                enabled: isLoading, child: _buildEventList(courseActivities))
          else
            SizedBox(
                height: 100,
                child:
                    Center(child: Text(AppIntl.of(context)!.schedule_no_event)))
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

  Widget _buildGradesCards(DashboardViewModel model, PreferencesFlag flag) {
    final bool loaded = !model.busy(model.courses);
    late List<Course> courses = model.courses;

    // When loading courses, there are 2 stages. First, the courses of user are fetched, then, grades are fetched.
    // During that first stage, putting empty courses with no title allows for a smoother transition.
    if (courses.isEmpty && !loaded) {
      final Course skeletonCourse = Course(
          acronym: " ",
          title: "",
          group: "",
          session: "",
          programCode: "",
          numberOfCredits: 0);
      courses = [
        skeletonCourse,
        skeletonCourse,
        skeletonCourse,
        skeletonCourse
      ];
    }

    return DismissibleCard(
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
            if (model.courses.isEmpty && loaded)
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
                enabled: !loaded,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
                  child: Wrap(
                    children: courses
                        .map((course) => GradeButton(course,
                            color: context.theme.appColors.backgroundAlt))
                        .toList(),
                  ),
                ),
              )
          ]),
    );
  }

  Widget _buildMessageBroadcastCard(DashboardViewModel model) {
    if (model.broadcastMessage == "" ||
        model.broadcastColor == "" ||
        model.broadcastTitle == "") {
      return const SizedBox.shrink();
    }
    final broadcastMsgColor = Color(int.parse(model.broadcastColor));
    final broadcastMsgType = model.broadcastType;
    final broadcastMsgUrl = model.broadcastUrl;
    return Card(
        key: UniqueKey(),
        color: broadcastMsgColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
          child: model.busy(model.broadcastMessage)
              ? const Center(child: CircularProgressIndicator())
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  // title row
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(model.broadcastTitle,
                              style: context.theme.primaryTextTheme.titleLarge),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          child: getBroadcastIcon(
                              broadcastMsgType, broadcastMsgUrl, context),
                        ),
                      ),
                    ],
                  ),
                  // main text
                  Text(model.broadcastMessage,
                    style: context.theme.primaryTextTheme.bodyMedium)
                ]),
        ));
  }

  Widget getBroadcastIcon(String type, String url, BuildContext context) {
    switch (type) {
      case "warning":
        return Icon(
          Icons.warning_rounded,
          color: context.theme.primaryTextTheme.titleLarge!.color,
          size: 36.0,
        );
      case "alert":
        return Icon(
          Icons.error,
          color: context.theme.primaryTextTheme.titleLarge!.color,
          size: 36.0,
        );
      case "link":
        return IconButton(
          onPressed: () {
            DashboardViewModel.launchBroadcastUrl(url);
          },
          icon: Icon(
            Icons.open_in_new,
            color: context.theme.primaryTextTheme.titleLarge!.color,
            size: 30.0,
          ),
        );
    }
    return Icon(
      Icons.campaign,
      color: Theme.of(context).primaryTextTheme.titleLarge!.color,
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
}
