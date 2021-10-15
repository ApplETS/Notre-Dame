// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/services/networking_service.dart';

// UTILS
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/ui/utils/loading.dart';
import 'package:notredame/ui/utils/app_theme.dart';

// WIDGETS
import 'package:notredame/ui/widgets/bottom_bar.dart';

import '../../locator.dart';

/// Basic Scaffold to avoid boilerplate code in the application.
/// Contains a loader controlled by [_isLoading]
class BaseScaffold extends StatefulWidget {
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
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  // Displays text under the app bar when offline.
  static bool _isOffline = false;

  final NetworkingService _networkingService = locator<NetworkingService>();

  StreamSubscription<ConnectivityResult> _subscription;

  @override
  void initState() {
    super.initState();
    _setOfflineValue();
    _listenToChangeInConnectivity();
  }

  Future _setOfflineValue() async {
    final isOffline = !await _networkingService.hasConnectivity();
    setState(() {
      _isOffline = isOffline;
    });
  }

  void _listenToChangeInConnectivity() {
    _subscription = _networkingService.onConnectivityChanged.listen((event) {
      setState(() {
        _isOffline = event == ConnectivityResult.none;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Scaffold(
          appBar: widget.appBar,
          body: SafeArea(
            top: false,
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
          bottomNavigationBar: widget._showBottomBar ? BottomBar() : null,
          floatingActionButton: widget.fab,
          floatingActionButtonLocation: widget.fabPosition,
        ),
        bottomNavigationBar: _isOffline ? buildOfflineBar(context) : null,
      );

  Widget buildOfflineBar(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Utils.getColorByBrightness(context,
              AppTheme.lightThemeBackground, AppTheme.darkThemeBackground),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 30,
        ),
        Text(
          AppIntl.of(context).no_connectivity,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    _subscription.cancel();
  }
}
