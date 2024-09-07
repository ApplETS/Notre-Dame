// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/constants/update_code.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/app/widgets/broadcast_card/message_broadcast_card.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';
import 'package:notredame/features/dashboard/widgets/about_us_card.dart';
import 'package:notredame/features/dashboard/widgets/grades_card.dart';
import 'package:notredame/features/dashboard/widgets/haptics_container.dart';
import 'package:notredame/features/dashboard/widgets/schedule_card/schedule_card.dart';
import 'package:notredame/features/dashboard/widgets/session_progress_card/session_progress_card.dart';
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/loading.dart';
import 'package:notredame/utils/locator.dart';

class DashboardView extends StatefulWidget {
  final UpdateCode updateCode;
  const DashboardView({super.key, required this.updateCode});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  Text? progressBarText;
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
                          header:
                              model.remoteConfigService.dashboardMessageActive
                                  ? const MessageBroadcastCard()
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
          cards.add(AboutUsCard(model, element, key: UniqueKey()));
        case PreferencesFlag.scheduleCard:
          cards.add(ScheduleCard(element,
              onDismissed: () => model.hideCard(element),
              key: UniqueKey(),
          ));
        case PreferencesFlag.progressBarCard:
          cards.add(SessionProgressCard(element, key: UniqueKey(),
              onDismissed: () => model.hideCard(element),
          ));
        case PreferencesFlag.gradesCard:
          cards.add(GradesCard(model, element, dismissCard: () =>
              model.hideCard(element),
              key: UniqueKey(),
          ));
        default:
      }
    }

    return cards;
  }

  void onReorder(DashboardViewModel model, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      // ignore: parameter_assignments
      newIndex -= 1;
    }

    // Should not happen because dismiss card will not be called if the card is null.
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
