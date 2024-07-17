// Flutter imports:
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String title;
  final String description;

  const QuestionCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                textScaler: TextScaler.noScaling,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 20,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                textAlign: TextAlign.justify,
              ),
              Text(
                description,
                textScaler: TextScaler.noScaling,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
