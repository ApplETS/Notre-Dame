// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// WIDGETS
import 'package:notredame/ui/widgets/bottom_bar.dart';

/// Basic Scaffold to avoid boilerplate code in the application.
/// Contains a loader controlled by [_isLoading]
class BaseScaffold extends StatelessWidget {
  final AppBar appBar;

  final Widget body;

  final bool _showBottomBar;

  final bool _isLoading;

  const BaseScaffold(
      {this.appBar,
      this.body,
      bool isLoading = false,
      bool showBottomBar = true})
      : _showBottomBar = showBottomBar,
        _isLoading = isLoading;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Stack(
            children: [
              body,
              if (_isLoading) _buildLoading() else const SizedBox()
            ],
          ),
        ),
        bottomNavigationBar: _showBottomBar ? BottomBar() : null,
      );

  Widget _buildLoading() => Stack(
        children: const [
          Opacity(
            opacity: 0.5,
            child: ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          Center(child: CircularProgressIndicator())
        ],
      );
}
