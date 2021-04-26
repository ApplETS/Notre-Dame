// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/constants/urls.dart';
import 'package:notredame/ui/utils/loading.dart';
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
  List<Widget> _buildCards;
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
        viewModelBuilder: () => DashboardViewModel(),
        builder: (context, model, child) {
          return BaseScaffold(
              isInteractionLimitedWhileLoading: false,
              appBar: AppBar(
                title: Text(AppIntl.of(context).title_dashboard),
                centerTitle: false,
                automaticallyImplyLeading: false,
                actions: _buildActionButtons(model),
              ),
              body: model.cards == null ? buildLoading():ReorderableListView(
                onReorder: (oldIndex, newIndex) =>
                    onReorder(model, oldIndex, newIndex),
                children: model.cards
                    . map((key) => _buildAboutUsCard(colorFor(key.toString())))
                    .toList(),
              ));
        });
  }

  /// Generate a color based on [text].
  Color colorFor(String text) {
    var hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (256 * 256 * 256);
    final red = (finalHash & 0xFF0000) >> 16;
    final blue = (finalHash & 0xFF00) >> 8;
    final green = finalHash & 0xFF;
    final color = Color.fromRGBO(red, green, blue, 1);
    return color;
  }

  Widget _buildAboutUsCard(Color color) {
    return Dismissible(
      key: Key(color.toString()),
      child: Card(
        key: Key(color.toString()),
        elevation: 1,
        color: color,
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
      ),
    );
  }

  void setAllVisible(DashboardViewModel model) => {
        setState(() {
          model.aboutUsCard = 1;
          model.scheduleCard = 2;
          model.progressBarCard = 3;
        })
      };

  void onReorder(DashboardViewModel model, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    model.setOrder(model.cards[oldIndex], newIndex);
  }

  List<Widget> _buildActionButtons(DashboardViewModel model) => [
        IconButton(
          icon: const Icon(Icons.restore),
          onPressed: () {
            setAllVisible(model);
          },
        ),
      ];
}
