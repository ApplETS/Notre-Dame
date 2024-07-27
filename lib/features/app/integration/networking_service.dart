// Dart imports:
import 'dart:async';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkingService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<bool> hasConnectivity() async {
    final connectionStatus = await _connectivity.checkConnectivity();
    return !connectionStatus.contains(ConnectivityResult.none);
  }

  Future<String> getConnectionType() async {
    final connectionStatus = await _connectivity.checkConnectivity();
    return connectionStatus.toString();
  }
}
