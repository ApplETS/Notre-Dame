// Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/core/services/firebase_storage_service.dart';
import '../helpers.dart';
import '../mock/services/firebase_storage_mock.dart';

void main() {
  FirebaseStorage firebaseStorageMock;
  ReferenceMock rootMock;
  ReferenceMock childMock;
  FirebaseStorageService service;

  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();

  group("FirebaseStorageService - ", () {
    setUp(() async {
      setupAnalyticsServiceMock();

      rootMock = ReferenceMock();
      childMock = ReferenceMock();
      firebaseStorageMock = FirebaseStorageMock();
      when(firebaseStorageMock.ref("app-images")).thenReturn(rootMock);

      when(firebaseStorageMock.ref("app-images")).thenReturn(rootMock);
      when(rootMock.child("test.png")).thenReturn(childMock);
      when(childMock.getDownloadURL())
          .thenAnswer((_) => Future.value("test-url"));

      service = FirebaseStorageService(firebaseStorage: firebaseStorageMock);
    });

    group("getImageUrl - ", () {
      test("get image url", () async {
        final url = await service.getImageUrl("test.png");
        verify(firebaseStorageMock.ref("app-images"));
        verify(rootMock.child("test.png"));
        verify(childMock.getDownloadURL());
        expect(url, isNotNull);
        expect(url, "test-url");
      });
    });
  });
}
