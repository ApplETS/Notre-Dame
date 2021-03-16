// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

class Discovery {
  final String path;
  final String featureId;
  final String title;
  final List<String> details;

  Discovery(
      {@required this.path,
      @required this.featureId,
      @required this.title,
      @required this.details});
}
