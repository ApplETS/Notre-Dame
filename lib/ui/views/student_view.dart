// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/core/constants/discovery_ids.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/utils/discovery_components.dart';
import 'package:notredame/ui/views/grades_view.dart';
import 'package:notredame/ui/views/profile_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

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
                        (index) => index == 1
                        ? _buildDiscoveryFeatureDescriptionWidget(
                        context, tabs, index)
                        : Tab(
                      text: tabs[index],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: SafeArea(
            child: TabBarView(
              children: tabsView,
            ),
          ),
        ),
      ),
    );
  }

  DescribedFeatureOverlay _buildDiscoveryFeatureDescriptionWidget(
      BuildContext context, List<String> tabs, int index) {
    final discovery = getDiscoveryByFeatureId(context,
        DiscoveryGroupIds.pageStudent, DiscoveryIds.detailsStudentProfile);

    return DescribedFeatureOverlay(
      overflowMode: OverflowMode.wrapBackground,
      contentLocation: ContentLocation.below,
      featureId: discovery.featureId,
      title: Text(discovery.title, textAlign: TextAlign.justify),
      description: discovery.details,
      backgroundColor: AppTheme.appletsDarkPurple,
      tapTarget: Tab(
        child: Text(
          tabs[index],
          style: (Theme.of(context).brightness == Brightness.dark)
              ? const TextStyle(color: Colors.black)
              : null,
        ),
      ),
      pulseDuration: const Duration(seconds: 5),
      child: Tab(
        text: tabs[index],
      ),
    );
  }
}