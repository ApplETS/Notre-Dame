// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/views/grades_view.dart';

// WIDGET
import 'package:notredame/ui/views/profile_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

// OTHER

class StudentView extends StatefulWidget {
  @override
  _StudentViewState createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  List<Widget> tabsView = [GradesView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [
      AppIntl.of(context).grades_title,
      AppIntl.of(context).profile_title
    ];

    return BaseScaffold(
      isInteractionLimitedWhileLoading: false,
      body: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                elevation: 4.0,
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                title: Text(AppIntl.of(context).title_student),
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  tabs: List.generate(
                    tabs.length,
                    (index) => Tab(
                      text: tabs[index],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: tabsView,
          ),
        ),
      ),
    );
  }
}
