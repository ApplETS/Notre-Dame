// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/widgets/about_us_card.dart';
import 'package:notredame/ui/dashboard/widgets/broadcast_message_card.dart';
import 'package:notredame/ui/dashboard/widgets/grades_card.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/schedule_card.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/haptics_container.dart';
import 'package:notredame/utils/loading.dart';
import 'package:notredame/locator.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

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
                        ? BroadcastMessageCard(key: UniqueKey(), model: model)
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
          cards.add(AboutUsCard(key: UniqueKey(), onDismissed: () => model.hideCard(PreferencesFlag.aboutUsCard)));
        case PreferencesFlag.scheduleCard:
          cards.add(ScheduleCard(key: UniqueKey(), model: model, onDismissed: () => model.hideCard(PreferencesFlag.scheduleCard)));
        case PreferencesFlag.progressBarCard:
          cards.add(ProgressBarCard(key: UniqueKey(), model: model, onDismissed: () => model.hideCard(PreferencesFlag.progressBarCard)));
        case PreferencesFlag.gradesCard:
          cards.add(GradesCard(key: UniqueKey(), model: model, onDismissed: () => model.hideCard(PreferencesFlag.gradesCard)));
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

    // Should not happen becase dismiss card will not be called if the card is null.
    if (model.cards == null) {
      _analyticsService.logError("DashboardView", "Cards list is null");
      throw Exception("Cards is null");
    }

    final PreferencesFlag elementMoved = model.cards!.keys
        .firstWhere((element) => model.cards![element] == oldIndex);

    model.setOrder(elementMoved, newIndex);
  }
}
