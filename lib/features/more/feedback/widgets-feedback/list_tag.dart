import 'package:flutter/material.dart';

class ListTag extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? color;

  const ListTag({
    Key? key,
    required this.text,
    this.textColor,
    this.color,
  }) : super(key: key);

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
