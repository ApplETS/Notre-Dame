// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget to add haptic feedback on an existing widget.
///
/// This is used to add haptic feedback on dashboard cards when reordering them:
/// when long-pressed, a new HapticsContainer widget holding the actual card
/// widget is created (through ReorderableListView's proxyDecorator) and haptic
/// feedback is generated.
class HapticsContainer extends StatefulWidget {
  final Widget child;

  const HapticsContainer({Key key, this.child}) : super(key: key);

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
    return widget.child;
  }
}
