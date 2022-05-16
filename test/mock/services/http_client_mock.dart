// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

/// Mock for the Http client
class HttpClientMock extends Mock implements http.Client {
  /// Stub the next post of [url] and return [jsonResponse] with [statusCode] as http response code.
  static void stubJsonPost(HttpClientMock client, String url,
      Map<String, dynamic> jsonResponse, int statusCode) {
    when(client.post(Uri.parse(url),
            headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer(
            (_) async => http.Response(jsonEncode(jsonResponse), statusCode));
  }

  /// Stub the next post request to [url] and return [response] with [statusCode] as http response code.
  static void stubPost(HttpClientMock client, String url, String response,
      [int statusCode = 200]) {
    when(client.post(Uri.parse(url),
            headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(response, statusCode));
  }
}
