// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/ets/events/news/news-details/news_details_viewmodel.dart';
import 'package:notredame/features/ets/events/report-news/report_news_widget.dart';
import 'package:notredame/features/schedule/calendar_selection_viewmodel.dart';
import 'package:notredame/features/schedule/widgets/calendar_selector.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/utils.dart';

class NewsDetailsView extends StatefulWidget {
  final News news;

  const NewsDetailsView({required this.news});

  @override
  _NewsDetailsViewState createState() => _NewsDetailsViewState();
}

enum Menu { share, export, report }

class _NewsDetailsViewState extends State<NewsDetailsView> {
  final NavigationService _navigationService = locator<NavigationService>();
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
                            _buildTitle(widget.news.title),
                            _buildDate(
                                context,
                                widget.news.publicationDate,
                                widget.news.eventStartDate,
                                widget.news.eventEndDate),
                            _buildImage(widget.news),
                            _buildAuthor(
                                widget.news.organizer.avatarUrl ?? "",
                                widget.news.organizer.organization ?? "",
                                widget.news.organizer.activityArea,
                                widget.news.organizer.id),
                            _buildContent(widget.news.content),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTags(model),
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

  Widget _buildContent(String content) {
    // TODO : Support underline
    String modifiedContent = content.replaceAll('<u>', "");
    modifiedContent = modifiedContent.replaceAll('</u>', "");

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MarkdownBody(data: modifiedContent),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color:
                Utils.getColorByBrightness(context, Colors.black, Colors.white),
            fontSize: 25,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImage(News news) {
    var isLoaded = false;
    return Hero(
      tag: 'news_image_id_${news.id}',
      child: (news.imageUrl == null || news.imageUrl == "")
          ? const SizedBox.shrink()
          : Image.network(
              news.imageUrl!,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                isLoaded = frame != null;
                return child;
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (isLoaded && loadingProgress == null) {
                  return child;
                } else {
                  return const ShimmerEffect();
                }
              },
            ),
    );
  }

  Widget _buildAuthor(
      String avatar, String author, ActivityArea? activity, String authorId) {
    return ColoredBox(
      color: Utils.getColorByBrightness(
          context, AppTheme.etsLightRed, AppTheme.darkThemeBackgroundAccent),
      child: ListTile(
        leading: GestureDetector(
            onTap: () => _navigationService.pushNamed(RouterPaths.newsAuthor,
                arguments: authorId),
            child: Hero(
                tag: 'news_author_avatar',
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Utils.getColorByBrightness(context,
                      AppTheme.lightThemeAccent, AppTheme.darkThemeAccent),
                  child: (avatar != "")
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.network(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  author.substring(0, 1),
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Utils.getColorByBrightness(
                                          context, Colors.black, Colors.white)),
                                ),
                              );
                            },
                          ))
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: Text(
                                author.substring(0, 1),
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Utils.getColorByBrightness(
                                        context, Colors.black, Colors.white)),
                              ),
                            ),
                          ],
                        ),
                ))),
        title: Text(
          author,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            activity != null
                ? Utils.getMessageByLocale(
                    context, activity.nameFr, activity.nameEn)
                : "",
            style: TextStyle(
              color: Utils.getColorByBrightness(
                  context, Colors.white, const Color(0xffbababa)),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDate(BuildContext context, DateTime publishedDate,
      DateTime eventStartDate, DateTime? eventEndDate) {
    final String locale = Localizations.localeOf(context).toString();
    final String formattedPublishedDate =
        DateFormat('d MMMM yyyy', locale).format(publishedDate);

    late String formattedEventDate;

    final bool sameMonthAndYear = eventEndDate?.month == eventStartDate.month &&
        eventEndDate?.year == eventStartDate.year;
    final bool sameDayMonthAndYear =
        eventEndDate?.day == eventStartDate.day && sameMonthAndYear;

    if (eventEndDate == null || sameDayMonthAndYear) {
      formattedEventDate =
          DateFormat('d MMMM yyyy', locale).format(eventStartDate);
    } else {
      if (sameMonthAndYear) {
        formattedEventDate =
            '${DateFormat('d', locale).format(eventStartDate)} - ${DateFormat('d MMMM yyyy', locale).format(eventEndDate)}';
      } else {
        formattedEventDate =
            '${DateFormat('d MMMM yyyy', locale).format(eventStartDate)} -\n${DateFormat('d MMMM yyyy', locale).format(eventEndDate)}';
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedPublishedDate,
                style: TextStyle(
                    color: Utils.getColorByBrightness(
                        context, Colors.black, Colors.white)),
              ),
              const SizedBox(height: 12.0),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Utils.getColorByBrightness(context,
                        AppTheme.darkThemeAccent, AppTheme.etsDarkGrey),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.event, size: 20.0, color: Colors.white),
                ),
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppIntl.of(context)!.news_event_date,
                        style: TextStyle(
                            color: Utils.getColorByBrightness(
                                context, Colors.black, AppTheme.etsLightGrey)),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        formattedEventDate,
                        style: TextStyle(
                            color: Utils.getColorByBrightness(context,
                                AppTheme.darkThemeAccent, Colors.white)),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(NewsDetailsViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              widget.news.tags.length,
              (index) => Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: model.getTagColor(widget.news.tags[index].name),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.news.tags[index].name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeBackground
          : AppTheme.darkThemeBackground,
      highlightColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeAccent
          : AppTheme.darkThemeAccent,
      child: Container(
        height: 200,
        color: Colors.grey,
      ),
    );
  }
}
