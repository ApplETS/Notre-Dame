// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:notredame/core/viewmodels/news_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:timeago/timeago.dart' as timeago;

// VIEWMODEL
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/dismissible_card.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/course_activity_tile.dart';
import 'package:notredame/ui/widgets/grade_button.dart';
import 'package:notredame/ui/widgets/haptics_container.dart';

// MODELS / CONSTANTS
import 'package:ets_api_clients/models.dart';
//import 'package:notredame/core/models/news.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/urls.dart';
import 'package:notredame/core/constants/discovery_ids.dart';
import 'package:notredame/core/constants/progress_bar_text_options.dart';
import 'package:notredame/core/constants/update_code.dart';
import 'package:notredame/core/constants/router_paths.dart';

// UTILS
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/ui/utils/loading.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/utils/discovery_components.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';

class DashboardView extends StatefulWidget {
  final UpdateCode updateCode;
  const DashboardView({Key key, this.updateCode}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  Text progressBarText;
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
    // TODO move this to a better place
    //timeago.setLocaleMessages('fr', timeago.FrShortMessages());
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
        viewModelBuilder: () => DashboardViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) {
          return BaseScaffold(
              isInteractionLimitedWhileLoading: false,
              appBar: AppBar(
                  title: Text(AppIntl.of(context).title_dashboard),
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
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                          children: _buildCards(
                              model /*, NewsViewModel(intl: AppIntl.of(context))*/),
                          proxyDecorator: (child, _, __) {
                            return HapticsContainer(child: child);
                          },
                        ),
                      ),
                      onRefresh: () => model.loadDataAndUpdateWidget(),
                    ));
        });
  }

  List<Widget> _buildCards(
      DashboardViewModel model /*, NewsViewModel newsModel*/) {
    final List<Widget> cards = List.empty(growable: true);

    for (final PreferencesFlag element in model.cardsToDisplay) {
      switch (element) {
        case PreferencesFlag.aboutUsCard:
          cards.add(_buildAboutUsCard(model, element));
          break;
        case PreferencesFlag.scheduleCard:
          cards.add(_buildScheduleCard(model, element));
          break;
        case PreferencesFlag.progressBarCard:
          cards.add(_buildProgressBarCard(model, element));
          break;
        case PreferencesFlag.gradesCard:
          cards.add(_buildGradesCards(model, element));
          // TODO : move to news page
          /*for (final News news in newsModel.news) {
            cards.add(_buildNewsCard(newsModel, news));
          }*/
          break;

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
                child: Text(AppIntl.of(context).card_applets_title,
                    style: Theme.of(context).primaryTextTheme.headline6),
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
                child: Text(AppIntl.of(context).card_applets_text,
                    style: Theme.of(context).primaryTextTheme.bodyText2),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Wrap(spacing: 15.0, children: [
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Facebook clicked");
                        Utils.launchURL(Urls.clubFacebook, AppIntl.of(context));
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.facebook,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Github clicked");
                        Utils.launchURL(Urls.clubGithub, AppIntl.of(context));
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.github,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Email clicked");
                        Utils.launchURL(Urls.clubEmail, AppIntl.of(context));
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.envelope,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _analyticsService.logEvent(tag, "Discord clicked");
                        Utils.launchURL(Urls.clubDiscord, AppIntl.of(context));
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
        isBusy: model.busy(model.progress),
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) {
          dismissCard(model, flag);
        },
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: Text(AppIntl.of(context).progress_bar_title,
                    style: Theme.of(context).textTheme.headline6),
              )),
          if (model.progress >= 0.0)
            Stack(children: [
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
                          AppIntl.of(context).progress_bar_message(
                              model.sessionDays[0], model.sessionDays[1]),
                          style: const TextStyle(color: Colors.white),
                        ),
                  ),
                ),
              ),
            ])
          else
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(AppIntl.of(context).session_without),
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
        AppIntl.of(context)
            .progress_bar_message(model.sessionDays[0], model.sessionDays[1]),
        style: const TextStyle(color: Colors.white),
      );
    } else if (model.currentProgressBarText == ProgressBarText.percentage) {
      progressBarText = Text(
        AppIntl.of(context).progress_bar_message_percentage(
            ((model.sessionDays[0] / model.sessionDays[1]) * 100).round()),
        style: const TextStyle(color: Colors.white),
      );
    } else {
      progressBarText = Text(
        AppIntl.of(context).progress_bar_message_remaining_days(
            model.sessionDays[1] - model.sessionDays[0]),
        style: const TextStyle(color: Colors.white),
      );
    }
  }

  Widget _buildScheduleCard(DashboardViewModel model, PreferencesFlag flag) {
    var title = AppIntl.of(context).title_schedule;
    if (model.todayDateEvents.isEmpty && model.tomorrowDateEvents.isNotEmpty) {
      title = title + AppIntl.of(context).card_schedule_tomorrow;
    }
    return DismissibleCard(
      isBusy: model.busy(model.todayDateEvents) ||
          model.busy(model.tomorrowDateEvents),
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
                  child:
                      Text(title, style: Theme.of(context).textTheme.headline6),
                ),
              )),
          if (model.todayDateEvents.isEmpty)
            if (model.tomorrowDateEvents.isEmpty)
              SizedBox(
                  height: 100,
                  child: Center(
                      child: Text(AppIntl.of(context).schedule_no_event)))
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
                    onTap: () => _navigationService
                        .pushNamedAndRemoveUntil(RouterPaths.student),
                    child: Text(AppIntl.of(context).grades_title,
                        style: Theme.of(context).textTheme.headline6),
                  ),
                ),
              ),
              if (model.courses.isEmpty)
                SizedBox(
                  height: 100,
                  child: Center(
                      child: Text(AppIntl.of(context)
                          .grades_msg_no_grades
                          .split("\n")
                          .first)),
                )
              else
                Container(
                  padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
                  child: Wrap(
                    children: model.courses
                        .map((course) =>
                            GradeButton(course, showDiscovery: false))
                        .toList(),
                  ),
                )
            ]),
      );
/* TODO : Move to news page
  Widget _buildImageWithTags(News news) {
  if (news.image == null) {
    return const SizedBox.shrink();
  }

  return Stack(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          news.image,
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        top: 8,
        left: 8,
        child: Wrap(
          spacing: 8,
          children: List.generate(
            news.tags.length,
            (index) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: news.tags[index].color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                news.tags[index].text,
                style: TextStyle(
                  color: _getTagTextColor(news.tags[index].color),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Color _getTagTextColor(Color backgroundColor) {
  final luminance = backgroundColor.computeLuminance();
  return luminance > 0.5 ? Colors.black : Colors.white;
}


  Widget _buildTitleAndTime(News news, BuildContext context) {
    final TextStyle titleStyle = news.important
        ? Theme.of(context).textTheme.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w500,
            );

    final TextStyle timeStyle = news.important && !Utils.isDarkTheme(context)
        ? Theme.of(context).textTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodySmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              news.title,
              style: titleStyle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          timeago.format(news.date, locale: AppIntl.of(context).localeName),
          style: timeStyle,
        ),
      ],
    );
  }

  Widget _buildNewsCard(NewsViewModel model, News news) {
    return DismissibleCard(
      cardColor: news.important ? AppTheme.accent : null,
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) {
        // Nothing for test
      },
      isBusy: model.busy(model.news),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageWithTags(news),
                const SizedBox(height: 8),
                _buildTitleAndTime(news, context),
              ],
            ),
          ),
        ],
      ),
    );
  }
*/
  void dismissCard(DashboardViewModel model, PreferencesFlag flag) {
    model.hideCard(flag);
  }

  void onReorder(DashboardViewModel model, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      // ignore: parameter_assignments
      newIndex -= 1;
    }

    final PreferencesFlag elementMoved = model.cards.keys
        .firstWhere((element) => model.cards[element] == oldIndex);

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
