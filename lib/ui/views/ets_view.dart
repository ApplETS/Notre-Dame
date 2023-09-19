// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// WIDGET
import 'package:notredame/ui/views/news_view.dart';
import 'package:notredame/ui/views/quick_links_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

class ETSView extends StatefulWidget {
  @override
  _ETSViewState createState() => _ETSViewState();
}

class _ETSViewState extends State<ETSView> {
  List<Widget> tabsView = [NewsView(), QuickLinksView()];

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [
      AppIntl.of(context).news_title,
      AppIntl.of(context).useful_link_title
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
                title: Text(AppIntl.of(context).title_ets),
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
