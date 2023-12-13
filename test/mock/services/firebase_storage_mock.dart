// Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/services/firebase_storage_service.dart';

/// Mock for the [FirebaseStorageService]
class FirebaseStorageServiceMock extends Mock
    implements FirebaseStorageService {}

/// Mock for the [FirebaseStorage]
// ignore: avoid_implementing_value_types
class FirebaseStorageMock extends Mock implements FirebaseStorage {}

/// Mock for the [Reference]
// ignore: avoid_implementing_value_types
class ReferenceMock extends Mock implements Reference {}
