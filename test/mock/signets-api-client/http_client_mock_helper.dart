// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/testing.dart';

/// Mock for the Http client
mixin HttpClientMockHelper {
  /// Stub the next post of [url] and return [jsonResponse] with [statusCode] as http response code.
  static MockClient stubJsonPost(String url, Map<String, dynamic> jsonResponse,
      [int statusCode = 200]) {
    return stubPost(url, jsonEncode(jsonResponse), statusCode);
  }

  /// Stub the next post request to [url] and return [response] with [statusCode] as http response code.
  static MockClient stubPost(String url, String response,
      [int statusCode = 200]) {
    return MockClient((Request r) {
      if (r.method == 'POST' && r.url == Uri.parse(url)) {
        return Future.value(Response(response, statusCode));
      }
      return Future.value(Response('', 500));
    });
  }

  /// Stub the next get of [url] and return [jsonResponse] with [statusCode] as http response code.
  static MockClient stubJsonGet(String url, Map<String, dynamic> jsonResponse,
      [int statusCode = 200]) {
    return stubGet(url, jsonEncode(jsonResponse), statusCode);
  }

  /// Stub the next get request to [url] and return [response] with [statusCode] as http response code.
  static MockClient stubGet(String url, String response,
      [int statusCode = 200]) {
    return MockClient((Request r) {
      if (r.method == 'GET' && r.url == Uri.parse(url)) {
        return Future.value(Response(response, statusCode));
      }
      return Future.value(Response('', 500));
    });
  }
}
