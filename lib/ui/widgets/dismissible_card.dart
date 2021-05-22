// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

class DismissibleCard extends StatelessWidget {
  final Widget child;

  final Function(DismissDirection) onDismissed;

  final Color cardColor;

  final double elevation;

  final bool isBusy;

  const DismissibleCard(
      {Key key,
        @required this.onDismissed,
        @required this.child,
        this.elevation = 1,
        this.cardColor,
        this.isBusy = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Dismissible(
      key: UniqueKey(),
      onDismissed: onDismissed,
      child: Card(
        elevation: elevation,
        color: cardColor,
        margin: const EdgeInsets.all(0),
        child: Stack(children: [
          child,
          if (isBusy)
            const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                      height: 15.0,
                      width: 15.0,
                      child: CircularProgressIndicator(strokeWidth: 3.0)),
                ))
        ]),
      ));
}