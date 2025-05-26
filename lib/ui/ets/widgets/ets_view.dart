// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/ets/events/news/widgets/news_view.dart';
import 'package:notredame/ui/ets/quick_links/widgets/quick_links_view.dart';

class ETSView extends StatefulWidget {
  const ETSView({super.key});

  @override
  State<ETSView> createState() => _ETSViewState();
}

class _ETSViewState extends State<ETSView> {
  final RemoteConfigService _remoteConfigService = locator<RemoteConfigService>();
  List<Widget> tabsView = [NewsView(), QuickLinksView()];

  @override
  Widget build(BuildContext context) {
    if (!_remoteConfigService.helloFeatureToggle) {
      return BaseScaffold(appBar: _buildAppBar(context), body: QuickLinksView());
    }

    final List<String> tabs = [AppIntl.of(context)!.news_title, AppIntl.of(context)!.useful_link_title];

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
                title: Text(AppIntl.of(context)!.title_ets),
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  indicatorColor: context.theme.appColors.tabBarIndicator,
                  labelColor: context.theme.appColors.tabBarLabel,
                  tabs: List.generate(tabs.length, (index) => Tab(text: tabs[index])),
                ),
              ),
            ];
          },
          body: TabBarView(children: tabsView),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(title: Text(AppIntl.of(context)!.title_ets), automaticallyImplyLeading: false, actions: const []);
  }
}
