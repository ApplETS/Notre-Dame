import 'package:flutter/material.dart';

class FaqSubtitle extends StatelessWidget {
  final String subtitle;
  final Color? backgroundColor;

  const FaqSubtitle({required this.subtitle, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, top: 18.0, bottom: 10.0),
      child: Text(
        subtitle,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: backgroundColor == Colors.white
                  ? Colors.black
                  : Colors.white,
            ),
      ),
    );
  }
}
