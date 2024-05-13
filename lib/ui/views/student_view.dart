// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/ui/views/grades_view.dart';
import 'package:notredame/ui/views/profile_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

class StudentView extends StatefulWidget {
  @override
  _StudentViewState createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> with TickerProviderStateMixin {
  List<Widget> tabsView = [GradesView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(length: 2, vsync: this);

    final List<Tab> tabs = [
      Tab(text: AppIntl.of(context)!.grades_title,),
      Tab(text: AppIntl.of(context)!.profile_title,),
    ];

    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: BaseScaffold(
          appBar: AppBar(
            title: Text(AppIntl.of(context)!.title_student),
            centerTitle: false,
            automaticallyImplyLeading: false,
          ),
          body:
          Column(
              children: [
                // give the tab bar a height [can change hheight to preferred height]
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceTint,
                  ),
                  child: TabBar(
                    indicatorColor:
                    (Theme.of(context).brightness == Brightness.dark)
                        ? Colors.white
                        : Colors.black26,
                    controller: tabController,
                    tabs: tabs,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: tabsView,
                  ),
                ),
              ]),
        ),
      ),
    );
  }

}
