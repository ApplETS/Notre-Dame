// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart' show rootBundle;

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/locator.dart';

const String _tag = "SignetsDio";

/// Create the [Dio] instance used to call the Signets API.
/// The Signets certificate is attached to the underlying [HttpClient].
Dio createSignetsDio() {
  final context = SecurityContext.defaultContext;

  rootBundle
      .load('assets/certificates/signets_cert.crt')
      .then((data) {
        context.setTrustedCertificatesBytes(data.buffer.asUint8List());
        locator<Logger>().d("$_tag - Certificate loaded successfully");
      })
      .catchError((Object e) {
        locator<Logger>().e("$_tag - Failed to load certificate: $e");
      });

  return Dio()..httpClientAdapter = IOHttpClientAdapter(createHttpClient: () => HttpClient(context: context));
}
