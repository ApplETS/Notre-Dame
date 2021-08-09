// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkingService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasConnectivity() async {
    final connectionStatus = await _connectivity.checkConnectivity();
    return connectionStatus != ConnectivityResult.none;
  }

  Future<String> getConnectionType() async {
    final connectionStatus = await _connectivity.checkConnectivity();
    return connectionStatus.toString();
  }
}
