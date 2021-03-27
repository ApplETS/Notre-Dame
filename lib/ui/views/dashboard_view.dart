// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/constants/urls.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';

// WIDGET
import 'package:notredame/ui/widgets/base_scaffold.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  CalendarController _calendarController;

  AnimationController _animationController;

  bool isAboutUsVisible = true;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
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
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<DashboardViewModel>.reactive(
        viewModelBuilder: () => DashboardViewModel(intl: null),
        builder: (context, model, child) => BaseScaffold(
          isInteractionLimitedWhileLoading: false,
          appBar: AppBar(
            title: Text(AppIntl.of(context).title_dashboard),
            centerTitle: false,
            automaticallyImplyLeading: false,
            actions: _buildActionButtons(),
          ),
          body: ListView(children: [
            if (isAboutUsVisible)
              Dismissible(
                key: UniqueKey(),
                onDismissed: (dismissDirection) => setState(() {
                  isAboutUsVisible = false;
                }),
                child: _buildAboutUsCard(),
              ),
            const SizedBox(height: 6.0),
          ]),
        ),
      );

  Widget _buildAboutUsCard() {
    return Card(
      elevation: 1,
      color: AppTheme.appletsPurple,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(17, 10, 0, 0),
              child: Text(AppIntl.of(context).card_applets_title,
                  style: Theme.of(context).primaryTextTheme.headline6),
            )),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
              child: Text(AppIntl.of(context).card_applets_text,
                  style: Theme.of(context).primaryTextTheme.bodyText2),
            ),
            Row(children: [
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  Utils.launchURL(Urls.clubFacebook, AppIntl.of(context));
                },
                child: Text(AppIntl.of(context).facebook.toUpperCase(),
                    style: Theme.of(context).primaryTextTheme.button),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  Utils.launchURL(Urls.clubGithub, AppIntl.of(context));
                },
                child: Text(AppIntl.of(context).github.toUpperCase(),
                    style: Theme.of(context).primaryTextTheme.button),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  Utils.launchURL(Urls.clubEmail, AppIntl.of(context));
                },
                child: Text(AppIntl.of(context).email.toUpperCase(),
                    style: Theme.of(context).primaryTextTheme.button),
              ),
            ]),
          ],
        ),
      ]),
    );
  }

  void setAllVisible() => {
        setState(() {
          isAboutUsVisible = true;
        })
      };

  List<Widget> _buildActionButtons() => [
        IconButton(
          icon: const Icon(Icons.restore),
          onPressed: () {
            setAllVisible();
          },
        ),
      ];
}
