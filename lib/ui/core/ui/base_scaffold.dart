// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

// Project imports:
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

/// Basic Scaffold to avoid boilerplate code in the application.
/// Contains a loader controlled by [_isLoading]
class BaseScaffold extends StatefulWidget {
  final AppBar? appBar;

  final Widget? body;

  final FloatingActionButton? fab;

  final FloatingActionButtonLocation? fabPosition;

  const BaseScaffold({super.key, this.appBar, this.body, this.fab, this.fabPosition});

  @override
  State<BaseScaffold> createState() => _BaseScaffoldState();
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
    appBar: (MediaQuery.of(context).orientation == Orientation.portrait) ? widget.appBar : null,
    body: (MediaQuery.of(context).orientation == Orientation.portrait) ? bodyPortraitMode() : bodyLandscapeMode(),
    floatingActionButton: widget.fab,
    floatingActionButtonLocation: widget.fabPosition,
  );

  Widget bodyPortraitMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(alignment: Alignment.center, children: [widget.body!, if (_isOffline) _buildOfflineBar()]),
    );
  }

  Widget bodyLandscapeMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            if (widget.appBar != null) widget.appBar!,
            Expanded(child: SafeArea(bottom: false, top: false, child: widget.body!)),
          ],
        ),
        if (_isOffline) _buildOfflineBar(),
      ],
    );
  }

  Widget _buildOfflineBar() {
    return Positioned(
      bottom: 32,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(color: AppPalette.etsLightRed, borderRadius: BorderRadius.circular(12.0)),
        child: Text(AppIntl.of(context)!.no_connectivity, textAlign: TextAlign.center),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _subscription.cancel();
  }
}
