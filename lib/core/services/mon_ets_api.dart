// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

// CONSTANTS & EXCEPTIONS
import 'package:notredame/core/constants/urls.dart';
import 'package:notredame/core/utils/http_exceptions.dart';

// MODEL
import 'package:notredame/core/models/mon_ets_user.dart';

// ANALYTICS
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/locator.dart';

class MonETSApi {
  static const String _tag = "MonETSApi";
  static const String _tagError = "$_tag - Error";

  final Client _client;

  MonETSApi(this._client);

  // Analytics used to log potentials error
  final _analytics = locator<AnalyticsService>();

  /// Get the basic MonETS user
  Future<MonETSUser> authenticate({@required String username, @required String password}) async {
    final response = await _client.post(Urls.authenticationMonETS, body: {"Username": username, "Password": password});

    // Log the http error and throw a exception
    if(response.statusCode != 200) {
      await _analytics.logError(_tagError, "${response.statusCode} - ${response.body}");
      throw HttpException(message: response.body, prefix: _tagError, code: response.statusCode);
    }
    return MonETSUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}