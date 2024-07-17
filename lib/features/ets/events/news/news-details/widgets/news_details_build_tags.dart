// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:notredame/features/ets/events/news/news-details/news_details_viewmodel.dart';

// Package imports:

// Project imports:

Widget newsTagSection(NewsDetailsViewModel model, News news) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            news.tags.length,
            (index) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: model.getTagColor(news.tags[index].name),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                news.tags[index].name,
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
