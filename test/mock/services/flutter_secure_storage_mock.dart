// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';

/// Mock for the [FlutterSecureStorage]
class FlutterSecureStorageMock extends Mock implements FlutterSecureStorage {
  /// Stub the read function of [FlutterSecureStorage]
  static void stubRead(FlutterSecureStorageMock mock,
      {@required String key, @required String valueToReturn}) {
    when(mock.read(key: key)).thenAnswer((_) async => valueToReturn);
  }

  /// Stub the read function of [FlutterSecureStorage] with an [Exception]
  static void stubReadException(FlutterSecureStorageMock mock,
      {@required String key, @required Exception exceptionToThrow}) {
    when(mock.read(key: key)).thenThrow(exceptionToThrow);
  }

  /// Stub the write function of [FlutterSecureStorage] with an [Exception]
  static void stubWriteException(FlutterSecureStorageMock mock,
      {@required String key, @required Exception exceptionToThrow}) {
    when(mock.write(key: key, value: anyNamed("value")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the delete function of [FlutterSecureStorage] with an [Exception]
  static void stubDeleteException(FlutterSecureStorageMock mock,
      {@required String key, @required Exception exceptionToThrow}) {
    when(mock.delete(key: key)).thenThrow(exceptionToThrow);
  }
}
