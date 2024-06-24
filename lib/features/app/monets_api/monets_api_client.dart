// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/monets_api/models/mon_ets_user.dart';
import 'package:notredame/utils/http_exception.dart';

/// A Wrapper for all calls to MonETS API.
class MonETSAPIClient {
  static const String tag = "MonETSApi";
  static const String tagError = "$tag - Error";

  final http.Client _httpClient;

  MonETSAPIClient({http.Client? client})
      : _httpClient = client ?? IOClient(HttpClient());

  /// Authenticate the basic MonETS user
  ///
  /// Throws an [HttpException] if the MonETSApi return anything
  /// else than a 200 code
  Future<MonETSUser> authenticate(
      {required String username, required String password}) async {
    final response = await _httpClient.post(
        Uri.parse(Urls.authenticationMonETS),
        body: {"Username": username, "Password": password});

    // Log the http error and throw a exception
    if (response.statusCode != 200) {
      throw HttpException(
          message: response.body, prefix: tagError, code: response.statusCode);
    }
    return MonETSUser.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
