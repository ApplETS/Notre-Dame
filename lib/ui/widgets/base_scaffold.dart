import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:notredame/ui/widgets/bottom_bar.dart';

class BaseScaffold extends StatelessWidget {
  final AppBar appBar;

  final Widget body;

  final bool _showBottomBar;

  final bool isLoading;

  const BaseScaffold(
      {this.appBar, this.body, this.isLoading, bool showBottomBar = true})
      : _showBottomBar = showBottomBar;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appBar,
        body: LoadingOverlay(color: Colors.grey.withOpacity(0.7),isLoading: isLoading, child: body),
        bottomNavigationBar: _showBottomBar ? BottomBar() : null,
      );
}
