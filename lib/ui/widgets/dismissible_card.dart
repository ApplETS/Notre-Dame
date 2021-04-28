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
        child: Stack(children: [child]),
      ));
}
