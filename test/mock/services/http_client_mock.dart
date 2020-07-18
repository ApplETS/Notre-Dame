// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Mock for the Http client
class HttpClientMock extends Mock implements http.Client {
  /// Stub the next post received
  static void stubPost(HttpClientMock client, String url, Map<String, dynamic> jsonResponse, int statusCode) {
    when(client.post(argThat(startsWith(url)), body: anyNamed('body')))
        .thenAnswer(
            (_) async => http.Response(jsonEncode(jsonResponse), statusCode));
  }
}
