/// A data type holding user feedback consisting of a feedback type and a feedback text.
class CustomFeedback {
  CustomFeedback({
    this.feedbackText,
  });

  String? feedbackText;
  String? feedbackEmail;

  @override
  String toString() {
    return {
      'feedback_text': feedbackText,
      'feedback_email': feedbackEmail,
    }.toString();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'feedback_text': feedbackText,
      'feedback_email': feedbackEmail,
    };
  }
}
