// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/haptics_container.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/schedule_card.dart';
import 'package:notredame/utils/loading.dart';
import 'about_us_card.dart';
import 'broadcast_message_card.dart';
import 'grades_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with TickerProviderStateMixin {
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
                      tooltip: AppIntl.of(context)!.dashboard_restore_all_cards_title,
                      onPressed: () => model.setAllCardsVisible(),
                    )
                  ],
                  automaticallyImplyLeading: false),
              body: model.cards == null
                  ? buildLoading()
                  : RefreshIndicator(
                      child: Theme(
                        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                        child: ReorderableListView(
                          header: model.remoteConfigService.dashboardMessageActive
                              ? BroadcastMessageCard(
                                  key: UniqueKey(),
                                  loading: model.busy(model.broadcastMessage),
                                  broadcastMessage: model.broadcastMessage)
                              : null,
                          onReorder: (oldIndex, newIndex) => model.onCardReorder(oldIndex, newIndex),
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

    for (final PreferencesFlag element in model.cardsToDisplay ?? []) {
      switch (element) {
        case PreferencesFlag.aboutUsCard:
          cards.add(AboutUsCard(key: UniqueKey(), onDismissed: () => model.hideCard(PreferencesFlag.aboutUsCard)));
        case PreferencesFlag.scheduleCard:
          cards.add(ScheduleCard(
              key: UniqueKey(),
              onDismissed: () => model.hideCard(PreferencesFlag.scheduleCard),
              events: model.scheduleEvents,
              loading: model.busy(model.scheduleEvents)));
        case PreferencesFlag.progressBarCard:
          cards.add(ProgressBarCard(
              key: UniqueKey(),
              onDismissed: () => model.hideCard(PreferencesFlag.progressBarCard),
              changeProgressBarText: model.changeProgressBarText,
              progressBarText: model.getProgressBarText(context),
              progress: model.progress,
              loading: model.busy(model.progress)));
        case PreferencesFlag.gradesCard:
          cards.add(GradesCard(
              key: UniqueKey(),
              courses: model.courses,
              onDismissed: () => model.hideCard(PreferencesFlag.gradesCard),
              loading: model.busy(model.courses)));
        default:
      }
    }

    return cards;
  }
}
