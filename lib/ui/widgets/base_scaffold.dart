// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/loading.dart';

// WIDGETS
import 'package:notredame/ui/widgets/bottom_bar.dart';

/// Basic Scaffold to avoid boilerplate code in the application.
/// Contains a loader controlled by [_isLoading]
class BaseScaffold extends StatelessWidget {
  final AppBar appBar;

  final Widget body;

  final FloatingActionButton fab;

  final FloatingActionButtonLocation fabPosition;

  final bool _showBottomBar;

  final bool _isLoading;

  /// If true, interactions with the UI is limited while loading.
  final bool _isInteractionLimitedWhileLoading;

  const BaseScaffold(
      {this.appBar,
      this.body,
      this.fab,
      this.fabPosition,
      bool isLoading = false,
      bool isInteractionLimitedWhileLoading = true,
      bool showBottomBar = true})
      : _showBottomBar = showBottomBar,
        _isLoading = isLoading,
        _isInteractionLimitedWhileLoading = isInteractionLimitedWhileLoading;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appBar,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              body,
              if (_isLoading)
                buildLoading(
                    isInteractionLimitedWhileLoading:
                        _isInteractionLimitedWhileLoading)
              else
                const SizedBox()
            ],
          ),
        ),
        bottomNavigationBar: _showBottomBar ? BottomBar() : null,
        floatingActionButton: fab,
        floatingActionButtonLocation: fabPosition,
      );
}
