import 'package:flutter/material.dart';
import 'package:notredame/features/ets/events/author/author_info_skeleton.dart';
import 'package:notredame/features/ets/events/author/author_viewmodel.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:stacked/stacked.dart';

class AvatarWidget extends ViewModelWidget<AuthorViewModel> {
  const AvatarWidget({super.key});

  @override
  Widget build(BuildContext context, AuthorViewModel model) {
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
                    backgroundColor: Utils.getColorByBrightness(
                        context, AppTheme.lightThemeAccent, AppTheme.darkThemeAccent),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (model.author?.avatarUrl != null && model.author!.avatarUrl != "")
                          ClipRRect(
                            borderRadius: BorderRadius.circular(120),
                            child: Image.network(
                              model.author!.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    model.author?.organization?.substring(0, 1) ?? '',
                                    style: TextStyle(
                                        fontSize: 56,
                                        color: Utils.getColorByBrightness(context, Colors.black, Colors.white)),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (model.author?.avatarUrl == null || model.author!.avatarUrl == "")
                          Center(
                            child: Text(
                              model.author?.organization?.substring(0, 1) ?? '',
                              style: TextStyle(
                                  fontSize: 56,
                                  color: Utils.getColorByBrightness(context, Colors.black, Colors.white)),
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
}
