// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/student/grades/widgets/grades_view.dart';
import 'package:notredame/ui/student/profile/widgets/profile_view.dart';

class StudentView extends StatefulWidget {
  const StudentView({super.key});

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  List<Widget> tabsView = [GradesView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [AppIntl.of(context)!.grades_title, AppIntl.of(context)!.profile_title];

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
                  indicatorColor: context.theme.appColors.tabBarIndicator,
                  labelColor: context.theme.appColors.tabBarLabel,
                  tabs: List.generate(tabs.length, (index) => Tab(text: tabs[index])),
                ),
              ),
            ];
          },
          body: SafeArea(top: false, bottom: false, child: TabBarView(children: tabsView)),
        ),
      ),
    );
  }
}
