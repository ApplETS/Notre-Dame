// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          content: Row(
            children: [
              Stack(
                children: const [
                  FaIcon(
                    FontAwesomeIcons.wifi,
                    color: Colors.white,
                  ),
                  FaIcon(
                    FontAwesomeIcons.slash,
                    color: Colors.white,
                  )
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Text(intl.no_connectivity),
            ],
          ),
          duration: const Duration(days: 365),
          action: SnackBarAction(
            label: intl.close_no_connectivity_snackbar.toUpperCase(),
            onPressed: () {
              _isSnackbarDismissed = true;
              ScaffoldMessenger.maybeOf(context).hideCurrentSnackBar();
            },
          ),
        );
        ScaffoldMessenger.maybeOf(context).showSnackBar(snackBar);
        _isSnackbarActive = true;
      }
    } else {
      // Remove snackbar when back online
      ScaffoldMessenger.maybeOf(context).hideCurrentSnackBar();
      _isSnackbarActive = false;
      _isSnackbarDismissed = false;
    }
  }

  Future<String> getConnectionType() async {
    final connectionStatus = await _connectivity.checkConnectivity();
    return connectionStatus.toString();
  }
}
