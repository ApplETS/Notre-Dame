// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/utils/utils.dart';
// Project imports:

Widget newsTitleSection(String title, BuildContext context) {
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
