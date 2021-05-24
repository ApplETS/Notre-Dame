// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/dismissible_card.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/urls.dart';

// UTILS
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/ui/utils/loading.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      DashboardViewModel(intl: AppIntl.of(context)).startDiscovery(context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
        viewModelBuilder: () => DashboardViewModel(
              intl: AppIntl.of(context),
            ),
        builder: (context, model, child) {
          return BaseScaffold(
              isInteractionLimitedWhileLoading: false,
              appBar: AppBar(
                  title: Text(AppIntl.of(context).title_dashboard),
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: model.setAllCardsVisible,
                    ),
                  ]),
              body: model.cards == null
                  ? buildLoading()
                  : ReorderableListView(
                      onReorder: (oldIndex, newIndex) =>
                          onReorder(model, oldIndex, newIndex),
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                      children: _buildCards(model),
                    ));
        });
  }

  List<Widget> _buildCards(DashboardViewModel model) {
    final List<Widget> cards = List.empty(growable: true);

    for (final PreferencesFlag element in model.cardsToDisplay) {
      switch (element) {
        case PreferencesFlag.aboutUsCard:
          cards.add(_buildAboutUsCard(model, element));
          break;
        case PreferencesFlag.scheduleCard:
          cards.add(Dismissible(
              key: UniqueKey(),
              onDismissed: (DismissDirection direction) {
                dismissCard(model, element);
              },
              child: Text(element.toString(), key: UniqueKey())));
          break;
        case PreferencesFlag.progressBarCard:
          cards.add(_buildProgressBarCard(model, element));
          break;
        default:
      }
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
                child: Wrap(spacing: 15.0, children: [
                  TextButton(
                    onPressed: () {
                      Utils.launchURL(Urls.clubFacebook, AppIntl.of(context));
                    },
                    child: Text(AppIntl.of(context).facebook.toUpperCase(),
                        style: Theme.of(context).primaryTextTheme.button),
                  ),
                  TextButton(
                    onPressed: () {
                      Utils.launchURL(Urls.clubGithub, AppIntl.of(context));
                    },
                    child: Text(AppIntl.of(context).github.toUpperCase(),
                        style: Theme.of(context).primaryTextTheme.button),
                  ),
                  TextButton(
                    onPressed: () {
                      Utils.launchURL(Urls.clubEmail, AppIntl.of(context));
                    },
                    child: Text(AppIntl.of(context).email.toUpperCase(),
                        style: Theme.of(context).primaryTextTheme.button),
                  ),
                ]),
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
                  child: LinearProgressIndicator(
                    value: model.progress,
                    minHeight: 30,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.gradeGoodMax),
                    backgroundColor: AppTheme.etsDarkGrey,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    AppIntl.of(context).progress_bar_message(
                        model.sessionDays[0], model.sessionDays[1]),
                    style: const TextStyle(color: Colors.white),
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
}
