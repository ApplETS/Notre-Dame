/// A data type holding user feedback consisting of a feedback type and a feedback text.
class CustomFeedback {
  CustomFeedback({
    this.feedbackType,
    this.feedbackText,
  });

  String feedbackType;
  String feedbackText;

  @override
  String toString() {
    return {
      'feedback_type': feedbackType,
      'feedback_text': feedbackText,
    }.toString();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'feedback_type': feedbackType,
      'feedback_text': feedbackText,
    };
  }
}
