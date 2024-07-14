// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/ets/events/news/news-details/widgets/news_details_build_author.dart';
import 'package:notredame/features/ets/events/news/news-details/widgets/news_details_build_content.dart';
import 'package:notredame/features/ets/events/news/news-details/widgets/news_details_build_date.dart';
import 'package:notredame/features/ets/events/news/news-details/widgets/news_details_build_image.dart';
import 'package:notredame/features/ets/events/news/news-details/widgets/news_details_build_tags.dart';
import 'package:notredame/features/ets/events/news/news-details/widgets/news_details_build_title.dart';
import 'package:notredame/features/ets/events/report-news/report_news_widget.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/features/schedule/calendar_selection_viewmodel.dart';
import 'package:notredame/features/schedule/widgets/calendar_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/ets/events/news/news-details/news_details_viewmodel.dart';

import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';

class NewsDetailsView extends StatefulWidget {
  final News news;

  const NewsDetailsView({required this.news});

  @override
  _NewsDetailsViewState createState() => _NewsDetailsViewState();
}

enum Menu { share, export, report }

class _NewsDetailsViewState extends State<NewsDetailsView> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final RemoteConfigService _remoteConfigService =
      locator<RemoteConfigService>();

  @override
  void initState() {
    super.initState();

    _analyticsService.logEvent("NewsDetailsView", "Opened");
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NewsDetailsViewModel>.reactive(
        viewModelBuilder: () => NewsDetailsViewModel(news: widget.news),
        builder: (context, model, child) => BaseScaffold(
          showBottomBar: false,
          body: Material(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? AppTheme.etsLightRed
                                : AppTheme.darkThemeBackgroundAccent,
                        pinned: true,
                        titleSpacing: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        title: Text(
                          AppIntl.of(context)!.news_details_title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                        ),
                        actions: <Widget>[
                          PopupMenuButton<Menu>(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            position: PopupMenuPosition.under,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: Utils.getColorByBrightness(
                                context,
                                AppTheme.lightThemeBackground,
                                AppTheme.darkThemeBackground),
                            icon: const Icon(Icons.more_vert),
                            onSelected: (Menu menu) =>
                                handleClick(menu, model.news),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<Menu>>[
                              PopupMenuItem<Menu>(
                                value: Menu.share,
                                child: ListTile(
                                  leading: const Icon(Icons.share_outlined),
                                  title: Text(AppIntl.of(context)!.share),
                                ),
                              ),
                              PopupMenuItem<Menu>(
                                value: Menu.export,
                                child: ListTile(
                                  leading: const Icon(Icons.ios_share),
                                  title: Text(AppIntl.of(context)!.export),
                                ),
                              ),
                              PopupMenuItem<Menu>(
                                value: Menu.report,
                                child: ListTile(
                                  leading: SvgPicture.asset(
                                    'assets/images/report.svg',
                                    colorFilter: const ColorFilter.mode(
                                        AppTheme.etsLightRed, BlendMode.srcIn),
                                    width: 26,
                                  ),
                                  title: Text(
                                    AppIntl.of(context)!.report,
                                    style: const TextStyle(
                                        color: AppTheme.etsLightRed),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            newsTitleSection(widget.news.title, context),
                            newsDateSection(
                                context,
                                widget.news.publicationDate,
                                widget.news.eventStartDate,
                                widget.news.eventEndDate),
                            newsImageSection(widget.news),
                            newsAuthorSection(
                                widget.news.organizer.avatarUrl ?? "",
                                widget.news.organizer.organization ?? "",
                                widget.news.organizer.activityArea,
                                widget.news.organizer.id,
                                context),
                            newsContentSection(widget.news.content),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                newsTagSection(model, widget.news),
              ],
            ),
          ),
        ),
      );

  void handleClick(Menu menu, News news) {
    switch (menu) {
      case Menu.share:
        Share.share(
            "${_remoteConfigService.helloWebsiteUrl}/fr/dashboard/news?id=${news.id}");
      case Menu.export:
        final translations = AppIntl.of(context)!;
        final viewModel =
            CalendarSelectionViewModel(translations: translations);
        viewModel.news = news;
        showDialog(
          context: context,
          builder: (_) => CalendarSelectionWidget(translations: translations),
        );
      case Menu.report:
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            builder: (context) => ReportNews(
                  newsId: news.id,
                ));
    }
  }
}
