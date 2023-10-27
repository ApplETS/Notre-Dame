// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart';

// Project imports:
import 'package:notredame/core/models/feedback_issue.dart';

void main() {
  group('FeedBackIssue - ', () {
    test('Constructor', () {
      final Issue issue = Issue(
          id: 1,
          title: 'title',
          body: 'body',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          state: 'open',
          number: 1,
          htmlUrl: 'htmlUrl');
      FeedbackIssue feedbackIssue = FeedbackIssue(issue);

      expect(feedbackIssue.id, 1);
      expect(feedbackIssue.htmlUrl, 'htmlUrl');
      expect(feedbackIssue.simpleDescription, 'body');
      expect(feedbackIssue.state, 'open');
      expect(feedbackIssue.isOpen, true);
      expect(feedbackIssue.number, 1);
      expect(feedbackIssue.createdAt, DateTime.now().toString().split(' ')[0]);

      issue.body = 'body```description```';
      feedbackIssue = FeedbackIssue(issue);

      expect(feedbackIssue.simpleDescription, 'description');

      issue.state = 'closed';
      feedbackIssue = FeedbackIssue(issue);

      expect(feedbackIssue.isOpen, false);
    });
  });
}
