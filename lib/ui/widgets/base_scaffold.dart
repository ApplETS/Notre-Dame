// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/bottom_bar.dart';
import 'package:notredame/ui/widgets/navigation_rail.dart';
import 'package:notredame/ui/utils/loading.dart';

/// Basic Scaffold to avoid boilerplate code in the application.
/// Contains a loader controlled by [_isLoading]
class BaseScaffold extends StatefulWidget {
  final AppBar? appBar;

  final Widget? body;

  final FloatingActionButton? fab;

  final FloatingActionButtonLocation? fabPosition;

  final bool _showBottomBar;

  final bool _safeArea;

  final bool _isLoading;

  /// If true, interactions with the UI is limited while loading.
  final bool _isInteractionLimitedWhileLoading;

  const BaseScaffold(
      {this.appBar,
      this.body,
      this.fab,
      this.fabPosition,
      bool isLoading = false,
        bool safeArea = true,
      bool isInteractionLimitedWhileLoading = true,
      bool showBottomBar = true})
      : _showBottomBar = showBottomBar,
        _isLoading = isLoading,
  _safeArea = safeArea,
        _isInteractionLimitedWhileLoading = isInteractionLimitedWhileLoading;

  @override
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  // Displays text under the app bar when offline.
  static bool _isOffline = false;

  final NetworkingService _networkingService = locator<NetworkingService>();

  late StreamSubscription<List<ConnectivityResult>> _subscription;

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
        _isOffline = event.contains(ConnectivityResult.none);
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Scaffold(
          appBar: (MediaQuery.of(context).orientation == Orientation.portrait)
              ? widget.appBar
              : null,
          body: (MediaQuery.of(context).orientation == Orientation.portrait)
              ? bodyPortraitMode()
              : bodyLandscapeMode(),
          bottomNavigationBar:
              (MediaQuery.of(context).orientation == Orientation.portrait &&
                      widget._showBottomBar)
                  ? BottomBar()
                  : null,
          floatingActionButton: widget.fab,
          floatingActionButtonLocation: widget.fabPosition,
        ),
        bottomNavigationBar: _isOffline ? buildOfflineBar(context) : null,
      );

  Widget bodyPortraitMode() {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          widget.body!,
          if (widget._isLoading)
            buildLoading(
                isInteractionLimitedWhileLoading:
                    widget._isInteractionLimitedWhileLoading)
          else
            const SizedBox()
        ],
      ),
    );
  }

  Widget bodyLandscapeMode() {
    return Stack(
      children: [
        Row(
          children: [
            if (widget._showBottomBar)
              ColoredBox(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppTheme.lightTheme().navigationRailTheme.backgroundColor!
                    : AppTheme.darkTheme().navigationRailTheme.backgroundColor!,
                child: SafeArea(
                    top: false, bottom: false, right: false, child: NavRail()),
            ),
            Expanded(
              child: Column(
                children: [
                  if (widget.appBar != null) widget.appBar!,
                    Expanded(
                      child: widget._safeArea
                          ? SafeArea(bottom: false, top: false, child: widget.body!)
                          : widget.body!,
                    )
                ],
              ),
            ),
          ],
        ),
        if (widget._isLoading)
          buildLoading(
              isInteractionLimitedWhileLoading:
                  widget._isInteractionLimitedWhileLoading)
        else
          const SizedBox()
      ],
    );
  }

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
          AppIntl.of(context)!.no_connectivity,
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
