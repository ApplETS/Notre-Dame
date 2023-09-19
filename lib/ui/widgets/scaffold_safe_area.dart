// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// UTILS
import 'package:notredame/ui/utils/loading.dart';

/// ScaffoldSafeArea to avoid boilerplate code in the application.
/// Contains a loader controlled by [_isLoading]
class ScaffoldSafeArea extends StatefulWidget {
  final Widget body;

  final bool _isLoading;

  /// If true, interactions with the UI is limited while loading.
  final bool _isInteractionLimitedWhileLoading;

  const ScaffoldSafeArea(
      {this.body,
      bool isLoading = false,
      bool isInteractionLimitedWhileLoading = true})
      : _isLoading = isLoading,
        _isInteractionLimitedWhileLoading = isInteractionLimitedWhileLoading;

  @override
  _ScaffoldSafeAreaState createState() => _ScaffoldSafeAreaState();
}

class _ScaffoldSafeAreaState extends State<ScaffoldSafeArea> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              widget.body,
              if (widget._isLoading)
                buildLoading(
                    isInteractionLimitedWhileLoading:
                        widget._isInteractionLimitedWhileLoading)
              else
                const SizedBox()
            ],
          ),
        ),
      );
}
