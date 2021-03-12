// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/src/widgets/dismissible.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/schedule_viewmodel.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

// WIDGET
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/course_activity_tile.dart';
import 'package:notredame/ui/widgets/schedule_settings.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardView extends StatefulWidget {
  @visibleForTesting
  final DateTime initialDay;

  const DashboardView({Key key, this.initialDay}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  static const Color _selectedColor = AppTheme.etsLightRed;

  static const Color _defaultColor = Color(0xff76859B);

  final DateFormat _dateFormat = DateFormat.MMMMEEEEd();

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
        viewModelBuilder: () => DashboardViewModel(
          intl: AppIntl.of(context),
        ),
        builder: (context, model, child) => BaseScaffold(
          isLoading: model.busy(model.isLoadingEvents),
          isInteractionLimitedWhileLoading: false,
          appBar: AppBar(
            title: Text(AppIntl.of(context).title_dashboard),
            centerTitle: false,
            automaticallyImplyLeading: false,
            actions: _buildActionButtons(),
          ),
          body: Column(mainAxisSize: MainAxisSize.min, children: [
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
                  launch('https://www.facebook.com/ClubApplETS');
                },
                child: Text(AppIntl.of(context).facebook.toUpperCase(),
                    style: Theme.of(context).primaryTextTheme.bodyText2),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  launch('https://github.com/ApplETS/Notre-Dame');
                },
                child: Text(AppIntl.of(context).github.toUpperCase(),
                    style: Theme.of(context).primaryTextTheme.button),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  launch('mailto:info@clubapplets.ca');
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
