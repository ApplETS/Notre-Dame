// Flutter imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/viewmodels/news_details_viewmodel.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/report_news.dart';

class NewsDetailsView extends StatefulWidget {
  final News news;

  const NewsDetailsView({required this.news});

  @override
  _NewsDetailsViewState createState() => _NewsDetailsViewState();
}

class _NewsDetailsViewState extends State<NewsDetailsView> {
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

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
                          IconButton(
                              icon: const Icon(Icons.warning_amber_sharp),
                              color: AppTheme.etsLightRed,
                              onPressed: () async {
                                await showModalBottomSheet(
                                    isDismissible: true,
                                    enableDrag: true,
                                    isScrollControlled: true,
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    builder: (context) => const ReportNews());
                              })
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
                                // TODO : Change to author image
                                widget.news.imageUrl ?? "",
                                widget.news.organizer.organization ?? "",
                                widget.news.organizer.activityArea ?? "",
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

  Widget _buildContent(String content) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          textAlign: TextAlign.justify,
        ),
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
    return Hero(
        tag: 'news_image_id_${news.id}',
        child: (news.imageUrl == null || news.imageUrl == "")
            ? const SizedBox.shrink()
            : Image.network(
                news.imageUrl!,
                fit: BoxFit.cover,
              ));
  }

  Widget _buildAuthor(
      String avatar, String author, String activity, String authorId) {
    return ColoredBox(
      color: Utils.getColorByBrightness(
          context, AppTheme.etsLightRed, AppTheme.darkThemeBackgroundAccent),
      child: ListTile(
        leading: GestureDetector(
            onTap: () => _navigationService.pushNamed(RouterPaths.newsAuthor,
                arguments: authorId),
            child: Hero(
                tag: 'news_author_avatar',
                child: ClipOval(
                  child: avatar == ""
                      ? const SizedBox()
                      : Image.network(
                          "https://cdn-icons-png.flaticon.com/512/147/147142.png",
                          fit: BoxFit.cover,
                          width: 50.0,
                          height: 50.0,
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
            activity,
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
