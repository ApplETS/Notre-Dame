// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class NetworkingService {
  final Connectivity _connectivity = Connectivity();

  // Offline mode snackbar
  static bool _isSnackbarDismissed = false;
  static bool _isSnackbarActive = false;

  Future<bool> hasConnectivity() async {
    final connectionStatus = await _connectivity.checkConnectivity();
    return connectionStatus != ConnectivityResult.none;
  }

  Future displayOfflineMode(BuildContext context, AppIntl intl) async {
    if (!await hasConnectivity()) {
      if (!_isSnackbarActive && !_isSnackbarDismissed) {
        final snackBar = SnackBar(
          content: Text(intl.no_connectivity),
          duration: const Duration(days: 365),
          action: SnackBarAction(
            label: intl.close_no_connectivity_snackbar.toUpperCase(),
            onPressed: () {
              _isSnackbarDismissed = true;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _isSnackbarActive = true;
      }
    } else {
      // Remove snackbar when back online
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _isSnackbarActive = false;
      _isSnackbarDismissed = false;
    }
  }

  Future<String> getConnectionType() async {
    final connectionStatus = await _connectivity.checkConnectivity();
    return connectionStatus.toString();
  }
}
