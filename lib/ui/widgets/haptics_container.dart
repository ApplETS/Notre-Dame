// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticsContainer extends StatefulWidget {
  final Widget content;

  const HapticsContainer({Key key, this.content}) : super(key: key);

  @override
  _HapticsContainerState createState() => _HapticsContainerState();
}

class _HapticsContainerState extends State<HapticsContainer> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return widget.content;
  }
}
