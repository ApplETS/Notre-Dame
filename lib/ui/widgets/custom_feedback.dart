import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/constants/feedback_types.dart';
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
                  Text(
                    Localizations.localeOf(context).toString() == 'fr'
                        ? "Quel type de signalement voulez-vous faire?"
                        : "What kind of feedback do you want to give?",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButton<FeedbackType>(
                          value: _customFeedback.feedbackType,
                          items: FeedbackType.values
                              .map(
                                (type) => DropdownMenuItem<FeedbackType>(
                                  value: type,
                                  child: Text(type.toString().split('.').last),
                                ),
                              )
                              .toList(),
                          onChanged: (feedbackType) => setState(() =>
                              _customFeedback.feedbackType = feedbackType),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                        labelText: FeedbackLocalizations.of(context)
                            .feedbackDescriptionText),
                    maxLines: 10,
                    minLines: 1,
                    textInputAction: TextInputAction.done,
                    onChanged: (newFeedback) =>
                        _customFeedback.feedbackText = newFeedback,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
        TextButton(
          // disable this button until the user has specified a feedback
          onPressed: _customFeedback.feedbackType != null &&
                  _customFeedback.feedbackText != null &&
                  _customFeedback.feedbackText.isNotEmpty
              ? () => widget.onSubmit(
                    _customFeedback.feedbackText,
                    extras: _customFeedback.toMap(),
                  )
              : null,
          child: Text(FeedbackLocalizations.of(context).submitButtonText),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
