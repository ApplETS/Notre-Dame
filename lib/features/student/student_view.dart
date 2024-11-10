// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/student/grades/grades_view.dart';
import 'package:notredame/features/student/profile/profile_view.dart';

class StudentView extends StatefulWidget {
  @override
  _StudentViewState createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  List<Widget> tabsView = [GradesView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [
      AppIntl.of(context)!.grades_title,
      AppIntl.of(context)!.profile_title
    ];

    return BaseScaffold(
      safeArea: false,
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
                title: Text(AppIntl.of(context)!.title_student),
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  indicatorColor:
                      (Theme.of(context).brightness == Brightness.dark)
                          ? Colors.white
                          : Colors.black26,
                  labelColor: (Theme.of(context).brightness == Brightness.dark)
                      ? Colors.white
                      : Colors.black,
                  tabs: List.generate(
                    tabs.length,
                    (index) => Tab(text: tabs[index]),
                  ),
                ),
              ),
            ];
          },
          body: SafeArea(
            top: false,
            bottom: false,
            child: TabBarView(
              children: tabsView,
            ),
          ),
        ),
      ),
    );
  }
}
