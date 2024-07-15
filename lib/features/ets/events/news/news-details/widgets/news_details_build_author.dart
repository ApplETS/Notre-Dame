// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/ets/events/api-client/models/activity_area.dart';

// Project imports:
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/utils.dart';

Widget newsAuthorSection(String avatar, String author, ActivityArea? activity,
    String authorId, BuildContext context) {
  final NavigationService navigationService = locator<NavigationService>();
  return ColoredBox(
    color: Utils.getColorByBrightness(
        context, AppTheme.etsLightRed, AppTheme.darkThemeBackgroundAccent),
    child: ListTile(
      leading: GestureDetector(
          onTap: () => navigationService.pushNamed(RouterPaths.newsAuthor,
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
