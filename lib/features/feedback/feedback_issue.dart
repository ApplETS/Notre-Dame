// Package imports:
import 'package:github/github.dart';

class FeedbackIssue {
  late int id;
  late String htmlUrl;
  late String simpleDescription;
  late String state;
  late bool isOpen;
  late int number;
  late String createdAt;

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
