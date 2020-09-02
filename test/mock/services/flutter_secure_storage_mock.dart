// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';

/// Mock for the [FlutterSecureStorage]
class FlutterSecureStorageMock extends Mock implements FlutterSecureStorage {
  /// Stub the read function of [FlutterSecureStorage]
  static void stubRead(FlutterSecureStorageMock mock, {@required String key, @required String valueToReturn}) {
    when(mock.read(key: key)).thenAnswer((_) async => valueToReturn);
  }
}