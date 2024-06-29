import 'package:flutter/material.dart';

class ListTag extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? color;

  const ListTag({
    super.key,
    required this.text,
    this.textColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
