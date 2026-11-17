// Flutter imports:
import 'package:flutter/material.dart';

const List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];

// Used to get the dimensions of the time. Supports scaling.
Size getTimeDimensions(TextStyle textStyle, TextDirection textDirection, TextScaler textScaler) {
  final textPainter = TextPainter(
    text: TextSpan(text: "00:00", style: textStyle),
    textDirection: textDirection,
    textScaler: textScaler,
  );

  textPainter.layout();

  return Size(textPainter.width, textPainter.height);
}
