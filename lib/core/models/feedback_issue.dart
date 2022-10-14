import 'package:flutter/widgets.dart';
import 'package:github/github.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeedbackIssue {
  int id;
  String htmlUrl;
  String simpleDescription;
  String state;
  bool isOpen;
  int number;
  String createdAt;
  // Constructor
  FeedbackIssue(Issue issue) {
    id = issue.id;
    htmlUrl = issue.htmlUrl;
    // Split inside the body to get the simple description
    final List<String> splitted = issue.body.split('```');
    simpleDescription = splitted.length > 1 ? splitted[1] : issue.body;
    state = issue.state;
    isOpen = issue.state == 'open';
    number = issue.number;
    createdAt = issue.createdAt.toString().split(' ')[0];
  }
}
