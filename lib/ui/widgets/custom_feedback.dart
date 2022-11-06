// FLUTTER / DART / THIRD-PARTIES
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

// CONSTANTS
import 'package:notredame/core/constants/custom_feedback_localization.dart';

// MODELS
import 'package:notredame/core/models/feedback.dart';

/// A form that prompts the user for the type of feedback they want to give and a
/// free form text feedback.
/// The submit button is disabled until the user provides the feedback type and a feedback text.
class CustomFeedbackForm extends StatefulWidget {
  const CustomFeedbackForm({
    Key key,
    this.onSubmit,
    this.scrollController,
  }) : super(key: key);

  final OnSubmit onSubmit;
  final ScrollController scrollController;

  @override
  _CustomFeedbackFormState createState() => _CustomFeedbackFormState();
}

class _CustomFeedbackFormState extends State<CustomFeedbackForm> {
  final CustomFeedback _customFeedback = CustomFeedback();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              if (widget.scrollController != null)
                const FeedbackSheetDragHandle(),
              ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: (FeedbackLocalizations.of(context) as CustomFeedbackLocalizations).email),
                    minLines: 1,
                    textInputAction: TextInputAction.done,
                    onChanged: (feedbackEmail) => _customFeedback.feedbackEmail = feedbackEmail,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: (FeedbackLocalizations.of(context) as CustomFeedbackLocalizations).feedbackDescriptionText),
                    maxLines: 10,
                    minLines: 1,
                    textInputAction: TextInputAction.done,
                    onChanged: (feedbackDescription) => _customFeedback.feedbackText = feedbackDescription,
                  ),
                ],
              ),
            ],
          ),
        ),
        TextButton(
          // disable this button until the user has specified a feedback
          onPressed: _customFeedback.feedbackText != null &&
                  _customFeedback.feedbackText.isNotEmpty
              ? () => widget.onSubmit(
                    _customFeedback.feedbackText,
                    extras: {
                      'email': _customFeedback.feedbackEmail,
                    },
                  )
              : null,
          child: Text(FeedbackLocalizations.of(context).submitButtonText),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
