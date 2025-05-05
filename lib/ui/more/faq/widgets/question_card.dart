// Flutter imports:
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String title;
  final String description;

  const QuestionCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.0,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: 20,
              ),
        ),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge!,
        ),
      ],
    );
  }
}
