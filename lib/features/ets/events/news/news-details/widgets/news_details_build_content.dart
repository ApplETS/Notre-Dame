// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';

// Package imports:

// Project imports:

Widget newsContentSection(String content) {
  // TODO : Support underline
  String modifiedContent = content.replaceAll('<u>', "");
  modifiedContent = modifiedContent.replaceAll('</u>', "");

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: MarkdownBody(data: modifiedContent),
    ),
  );
}
