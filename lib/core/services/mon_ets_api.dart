// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

// CONSTANTS & EXCEPTIONS
import 'package:notredame/core/constants/urls.dart';
import 'package:notredame/core/utils/http_exceptions.dart';

// MODEL
import 'package:notredame/core/models/mon_ets_user.dart';

class MonETSApi {
  static const String tag = "MonETSApi";
  static const String tagError = "$tag - Error";

  final Client _client;

  MonETSApi(this._client);

  /// Get the basic MonETS user
  ///
  /// Throws an [HttpException] if the MonETSApi return anything else than a 200 code
  Future<MonETSUser> authenticate(
      {@required String username, @required String password}) async {
    final response = await _client.post(Uri.parse(Urls.authenticationMonETS),
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
