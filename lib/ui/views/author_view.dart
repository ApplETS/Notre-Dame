// Flutter imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/viewmodels/author_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/author_info_skeleton.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/news_card.dart';
import 'package:notredame/ui/widgets/news_card_skeleton.dart';
import 'package:notredame/ui/widgets/social_links_card.dart';

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
            authorId: widget.authorId, appIntl: AppIntl.of(context)!),
        builder: (context, model, child) {
          notifyBtnText = getNotifyMeBtnText(model);

          return BaseScaffold(
            showBottomBar: false,
            body: RefreshIndicator(
              onRefresh: () => Future.sync(
                () => model.pagingController.refresh(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                      children: [
                        Stack(
                          children: [
                            _buildBackButton(),
                            _buildAuthorInfo(model),
                            _buildAvatar(model, widget.authorId),
                          ],
                        ),
                        /*PagedListView<int, News>(
                          key: const Key("pagedListView"),
                          pagingController: model.pagingController,
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                          builderDelegate: PagedChildBuilderDelegate<News>(
                            itemBuilder: (context, item, index) =>
                                NewsCard(item),
                            firstPageProgressIndicatorBuilder: (context) =>
                                _buildSkeletonLoader(),
                            newPageProgressIndicatorBuilder: (context) =>
                                NewsCardSkeleton(),
                            noMoreItemsIndicatorBuilder: (context) =>
                                _buildNoMoreNewsCard(),
                            firstPageErrorIndicatorBuilder: (context) =>
                                _buildError(model.pagingController),
                          ),
                        ),*/
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildAuthorInfo(AuthorViewModel model) {
    final author = model.author;

    return Padding(
      padding: const EdgeInsets.only(top: 76),
      child: model.busy(model.isLoadingEvents)
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
                      Text(
                        author?.organisation ?? "",
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        author?.description ?? "",
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    return Utils.getColorByBrightness(
                                      context,
                                      AppTheme.newsAccentColorLight,
                                      AppTheme.newsAccentColorDark,
                                    );
                                  },
                                ),
                              ),
                              onPressed: () {
                                model.notifyMe();
                                setState(() {
                                  notifyBtnText = getNotifyMeBtnText(model);
                                });
                              },
                              child: Align(
                                child: Text(
                                  notifyBtnText,
                                  style: TextStyle(
                                    color: Utils.getColorByBrightness(
                                      context,
                                      const Color(0xFFFFFFFF),
                                      AppTheme.primaryDark,
                                    ),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () async {
                              await showModalBottomSheet(
                                isDismissible: true,
                                enableDrag: true,
                                isScrollControlled: true,
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                builder: (context) => SocialLinks(
                                  socialLinks: model.author?.socialLinks ?? [],
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
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
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
    return model.busy(model.isLoadingEvents)
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
                  child: ClipOval(
                    child:
                        model.author?.image == "" || model.author?.image == null
                            ? const SizedBox()
                            : Image.network(
                                model.author!.image,
                                fit: BoxFit.cover,
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
