import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notredame/core/viewmodels/profile_viewmodel.dart';
import 'package:notredame/ui/views/profile_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:stacked/stacked.dart';

// OTHER
import 'package:notredame/generated/l10n.dart';

class StudentView extends StatefulWidget {
  @override
  _StudentViewState createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  List<String> tabs = [
    AppIntl.current.grades_title,
    AppIntl.current.profile_title
  ];

  List<Widget> tabsView = [Scaffold(), ProfileView()];

  @override
  Widget build(BuildContext context) => DefaultTabController(
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
      );
}
