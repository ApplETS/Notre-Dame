import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notredame/ui/widgets/author_info_skeleton.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/viewmodels/author_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/news_card.dart';
import 'package:notredame/ui/widgets/news_card_skeleton.dart';
import 'package:notredame/ui/widgets/social_links_card.dart';
import 'package:stacked/stacked.dart';

class AuthorView extends StatefulWidget {
  final int authorId;

  const AuthorView({required this.authorId});

  @override
  State<AuthorView> createState() => _AuthorViewState();
}

class _AuthorViewState extends State<AuthorView> {
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
              onRefresh: model.refresh,
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
                        ..._buildNewsCards(model),
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
                        author.organisation,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        author.description,
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
                                  socialLinks: model.author.socialLinks,
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

  Widget _buildAvatar(AuthorViewModel model, int authorId) {
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
                    child: model.author.image.isEmpty
                        ? const SizedBox()
                        : Image.network(
                            model.author.image,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
          );
  }

  List<Widget> _buildSkeletonLoader() {
    return List.generate(
      3,
      (index) => NewsCardSkeleton(),
    );
  }

  List<Widget> _buildNewsCards(AuthorViewModel model) {
    return model.busy(model.isLoadingEvents)
        ? _buildSkeletonLoader()
        : model.news.map((news) => NewsCard(news)).toList();
  }
}
