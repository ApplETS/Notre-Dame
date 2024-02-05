// FLUTTER / DART / THIRD-PARTIES
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/viewmodels/news_details_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/report_news.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';

// OTHER
import 'package:notredame/locator.dart';

class NewsDetailsView extends StatefulWidget {
  final News news;

  const NewsDetailsView({required this.news});

  @override
  _NewsDetailsViewState createState() => _NewsDetailsViewState();
}

class _NewsDetailsViewState extends State<NewsDetailsView> {
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
            child: NestedScrollView(
              physics: const ClampingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxScrolled) => [
                SliverAppBar(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? AppTheme.etsLightRed
                          : Theme.of(context).bottomAppBarColor,
                  pinned: true,
                  onStretchTrigger: () {
                    return Future<void>.value();
                  },
                  titleSpacing: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    AppIntl.of(context)!.news_details_title,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
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
              ],
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitle(widget.news.title),
                    _buildDate(context, widget.news.publishedDate,
                        widget.news.eventDate),
                    _buildImage(widget.news.image),
                    _buildAuthor(widget.news.avatar, widget.news.author,
                        widget.news.activity),
                    _buildContent(widget.news.description),
                    const Spacer(),
                    _buildTags(model),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImage(String image) {
    if (image == null) {
      return const SizedBox.shrink();
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
    );
  }

  Widget _buildAuthor(String avatar, String author, String activity) {
    return Container(
      color: const Color(0xff1e1e1e),
      child: ListTile(
        leading: ClipOval(
          child: Image.network(
            avatar,
            fit: BoxFit.cover,
            width: 50.0,
            height: 50.0,
          ),
        ),
        title: Text(
          author,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            activity,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDate(
      BuildContext context, DateTime publishedDate, DateTime eventDate) {
    final String formattedPublishedDate =
        DateFormat('d MMMM yyyy', Localizations.localeOf(context).toString())
            .format(publishedDate);
    final String formattedEventDate =
        DateFormat('d MMMM yyyy', Localizations.localeOf(context).toString())
            .format(eventDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                formattedPublishedDate,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12.0),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.etsDarkGrey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event,
                        size: 20.0, color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppIntl.of(context)!.news_event_date,
                          style: const TextStyle(color: AppTheme.etsLightGrey),
                        ),
                        Text(
                          formattedEventDate,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        content,
        textAlign: TextAlign.justify,
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
                  color: model.getTagColor(widget.news.tags[index]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.news.tags[index],
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
