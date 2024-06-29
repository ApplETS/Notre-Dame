import 'package:flutter/material.dart';

class CourseGradeSummary extends StatelessWidget {
  final String? title;
  final String number;

  const CourseGradeSummary({required this.title, required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      width: MediaQuery.of(context).size.width / 3.1,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Text(
                  title ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  number,
                  style: const TextStyle(fontSize: 19),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
