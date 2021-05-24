import 'dart:convert';

import 'package:flutter/services.dart';

/// TestAssetBundle is required in order to avoid issues with large assets
///
/// ref: https://medium.com/@sardox/flutter-test-and-randomly-missing-assets-in-goldens-ea959cdd336a
///
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    //overriding this method to avoid limit of 10KB per asset
    final data = await load(key);
    return utf8.decode(data.buffer.asUint8List());
  }

  @override
  Future<ByteData> load(String key) async => rootBundle.load(key);
}