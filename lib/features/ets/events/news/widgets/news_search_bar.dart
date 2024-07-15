// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/features/ets/events/news/news_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

class NewsSearchBar extends StatelessWidget {
  const NewsSearchBar({
    super.key,
    required this.model,
  });

  final NewsViewModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 52,
        child: TextField(
          decoration: InputDecoration(
              hintText: AppIntl.of(context)!.search,
              filled: true,
              fillColor: Utils.getColorByBrightness(context,
                  AppTheme.lightThemeAccent, Theme.of(context).cardColor),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0)),
          style: const TextStyle(fontSize: 18),
          onEditingComplete: () => {model.searchNews(model.query)},
          onChanged: (query) {
            model.query = query;
          },
        ));
  }
}
