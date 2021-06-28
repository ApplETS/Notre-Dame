// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/views/grades_view.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/utils/discovery_components.dart';

// WIDGET
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
          body: TabBarView(
            children: tabsView,
          ),
        ),
      ),
    );
  }

  DescribedFeatureOverlay _buildDiscoveryFeatureDescriptionWidget(
      BuildContext context, List<String> tabs, int index) {
    final discovery = getDiscoveryByFeatureId(
        context, 'pageStudent', 'page_student_page_profile');

    return DescribedFeatureOverlay(
      overflowMode: OverflowMode.wrapBackground,
      contentLocation: ContentLocation.below,
      featureId: discovery.featureId,
      title: Text(discovery.title, textAlign: TextAlign.justify),
      description: discovery.details,
      backgroundColor: AppTheme.appletsDarkPurple,
      tapTarget: Tab(
        text: tabs[index],
      ),
      pulseDuration: const Duration(seconds: 5),
      child: Tab(
        text: tabs[index],
      ),
    );
  }
}
