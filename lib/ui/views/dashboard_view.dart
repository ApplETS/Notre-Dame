// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/constants/urls.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/utils/loading.dart';
import 'package:notredame/ui/widgets/dismissible_card.dart';
import 'package:notredame/ui/widgets/grade_button.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';

// WIDGET
import 'package:notredame/ui/widgets/base_scaffold.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  CalendarController _calendarController;

  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
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
                actions: _buildActionButtons(model),
              ),
              body: model.cards == null
                  ? buildLoading()
                  : ReorderableListView(
                      onReorder: (oldIndex, newIndex) =>
                          onReorder(model, oldIndex, newIndex),
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
          cards.add(Dismissible(
              key: UniqueKey(),
              onDismissed: (DismissDirection direction) {
                dismissCard(model, element);
              },
              child: Text(element.toString())));
          break;
        case PreferencesFlag.gradesCards:
          cards.add(_buildGradesCards(model, element));
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
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppIntl.of(context).card_applets_title,
                  style: Theme.of(context).primaryTextTheme.headline6),
              const SizedBox(height: 10),
              Text(AppIntl.of(context).card_applets_text,
                  style: Theme.of(context).primaryTextTheme.bodyText2),
              const SizedBox(height: 10),
              Wrap(spacing: 15.0, children: [
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
            ]),
      );

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
              Text(AppIntl.of(context).grades_title,
                  style: Theme.of(context).primaryTextTheme.headline6),
              const SizedBox(height: 10),
              if (model.courses.isEmpty)
                Center(
                    child: Text(AppIntl.of(context)
                        .grades_msg_no_grades
                        .split("\n")
                        .first))
              else
                Wrap(
                  children: model.courses
                      .map((course) => GradeButton(course))
                      .toList(),
                )
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

    model.setOrder(elementMoved, newIndex, oldIndex);
  }

  List<Widget> _buildActionButtons(DashboardViewModel model) => [
        IconButton(
          icon: const Icon(Icons.restore),
          onPressed: model.setAllCardsVisible,
        ),
      ];
}
