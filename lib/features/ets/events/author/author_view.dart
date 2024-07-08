// Flutter imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:notredame/features/ets/events/social/models/social_link.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/utils/utils.dart';
import 'package:notredame/features/ets/events/author/author_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/features/ets/events/author/author_info_skeleton.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/ets/events/news/widgets/news_card.dart';
import 'package:notredame/features/ets/events/news/widgets/news_card_skeleton.dart';
import 'package:notredame/features/ets/events/social/social_links_card.dart';

class AuthorView extends StatefulWidget {
  final String authorId;

  const AuthorView({required this.authorId});

  @override
  State<AuthorView> createState() => _AuthorViewState();
}

class _AuthorViewState extends State<AuthorView> {
  static const int _nbSkeletons = 3;
  late String notifyBtnText;

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<AuthorViewModel>.reactive(
          viewModelBuilder: () => AuthorViewModel(
              authorId: widget.authorId, appIntl: AppIntl.of(context)),
          onViewModelReady: (model) {
            model.fetchAuthorData();
            model.pagingController.addStatusListener((status) {
              if (status == PagingStatus.subsequentPageError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppIntl.of(context)!.news_error_not_found,
                    ),
                    action: SnackBarAction(
                      label: AppIntl.of(context)!.retry,
                      onPressed: () =>
                          model.pagingController.retryLastFailedRequest(),
                    ),
                  ),
                );
              }
            });
          },
          builder: (context, model, child) => BaseScaffold(
                showBottomBar: false,
                body: RefreshIndicator(
                    onRefresh: () => Future.sync(
                          () => model.pagingController.refresh(),
                        ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(canvasColor: Colors.transparent),
                      child: Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  _buildBackButton(),
                                  _buildAuthorInfo(model),
                                  _buildAvatar(model, widget.authorId),
                                ],
                              ),
                              Expanded(
                                child: PagedListView<int, News>(
                                  key: const Key("pagedListView"),
                                  pagingController: model.pagingController,
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 4, 0, 8),
                                  builderDelegate:
                                      PagedChildBuilderDelegate<News>(
                                    itemBuilder: (context, item, index) =>
                                        NewsCard(item),
                                    firstPageProgressIndicatorBuilder:
                                        (context) => _buildSkeletonLoader(),
                                    newPageProgressIndicatorBuilder:
                                        (context) => NewsCardSkeleton(),
                                    noMoreItemsIndicatorBuilder: (context) =>
                                        _buildNoMoreNewsCard(),
                                    firstPageErrorIndicatorBuilder: (context) =>
                                        _buildError(model.pagingController),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    )),
              ));

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildAuthorInfo(AuthorViewModel model) {
    notifyBtnText = getNotifyMeBtnText(model);

    final author = model.author;

    List<SocialLink> socialLinks = [];
    if (author != null) {
      socialLinks = [
        if (author.email != null)
          SocialLink(id: 0, name: 'Email', link: author.email!),
        if (author.facebookLink != null)
          SocialLink(id: 1, name: 'Facebook', link: author.facebookLink!),
        if (author.instagramLink != null)
          SocialLink(id: 2, name: 'Instagram', link: author.instagramLink!),
        if (author.tikTokLink != null)
          SocialLink(id: 3, name: 'TikTok', link: author.tikTokLink!),
        if (author.xLink != null)
          SocialLink(id: 4, name: 'X', link: author.xLink!),
        if (author.redditLink != null)
          SocialLink(id: 5, name: 'Reddit', link: author.redditLink!),
        if (author.discordLink != null)
          SocialLink(id: 6, name: 'Discord', link: author.discordLink!),
        if (author.linkedInLink != null)
          SocialLink(id: 7, name: 'LinkedIn', link: author.linkedInLink!),
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(top: 76),
      child: model.isBusy
          ? AuthorInfoSkeleton()
          : SizedBox(
              width: double.infinity,
              child: Card(
                color: Utils.getColorByBrightnessNullable(
                    context, AppTheme.newsSecondaryColor, null),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                key: UniqueKey(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 64, 32, 16),
                  child: Column(
                    children: [
                      if (author?.organization != null ||
                          author?.organization != "")
                        Text(
                          author?.organization ?? "",
                          style: const TextStyle(fontSize: 26),
                        ),
                      if (author?.organization != null &&
                          author?.organization != "")
                        const SizedBox(height: 8),
                      if (author?.profileDescription != null &&
                          author?.profileDescription != "")
                        Text(
                          author?.profileDescription ?? "",
                          style: TextStyle(
                            color: Utils.getColorByBrightness(
                              context,
                              AppTheme.etsDarkGrey,
                              AppTheme.newsSecondaryColor,
                            ),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (author?.profileDescription != null &&
                          author?.profileDescription != "")
                        const SizedBox(height: 8),
                      IconButton(
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            builder: (context) => SocialLinks(
                              socialLinks: socialLinks,
                            ),
                          );
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.link,
                          color: Utils.getColorByBrightness(
                            context,
                            AppTheme.newsAccentColorLight,
                            AppTheme.newsAccentColorDark,
                          ),
                        ),
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Utils.getColorByBrightness(
                              context,
                              AppTheme.lightThemeBackground,
                              AppTheme.darkThemeBackground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String getNotifyMeBtnText(AuthorViewModel model) {
    return model.isNotified
        ? AppIntl.of(context)!.news_author_dont_notify_me
        : AppIntl.of(context)!.news_author_notify_me;
  }

  Widget _buildAvatar(AuthorViewModel model, String authorId) {
    return model.isBusy
        ? AvatarSkeleton()
        : Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Hero(
                  tag: 'news_author_avatar',
                  child: CircleAvatar(
                    backgroundColor: Utils.getColorByBrightness(context,
                        AppTheme.lightThemeAccent, AppTheme.darkThemeAccent),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (model.author?.avatarUrl != null &&
                            model.author!.avatarUrl != "")
                          ClipRRect(
                              borderRadius: BorderRadius.circular(120),
                              child: Image.network(
                                model.author!.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      model.author?.organization
                                              ?.substring(0, 1) ??
                                          '',
                                      style: TextStyle(
                                          fontSize: 56,
                                          color: Utils.getColorByBrightness(
                                              context,
                                              Colors.black,
                                              Colors.white)),
                                    ),
                                  );
                                },
                              )),
                        if (model.author?.avatarUrl == null ||
                            model.author!.avatarUrl == "")
                          Center(
                            child: Text(
                              model.author?.organization?.substring(0, 1) ?? '',
                              style: TextStyle(
                                  fontSize: 56,
                                  color: Utils.getColorByBrightness(
                                      context, Colors.black, Colors.white)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildSkeletonLoader() {
    final Widget skeleton = NewsCardSkeleton();
    return Column(children: [
      for (var i = 0; i < _nbSkeletons; i++) skeleton,
    ]);
  }

  Widget _buildNoMoreNewsCard() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        const SizedBox(height: 16),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.blue, size: 40),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppIntl.of(context)!.news_no_more_card_title,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 16),
                            Text(
                              AppIntl.of(context)!.news_no_more_card,
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(PagingController<int, News> pagingController) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 80,
                ),
                child: Text(
                  AppIntl.of(context)!.news_error_not_found_title,
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 70,
                ),
                child: Text(
                  AppIntl.of(context)!.news_error_not_found,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    pagingController.retryLastFailedRequest();
                  },
                  child: Text(AppIntl.of(context)!.retry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
