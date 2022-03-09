// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// MODELS
import 'package:notredame/core/models/discovery.dart';

class GroupDiscovery {
  final String name;
  final List<Discovery> discoveries;

  GroupDiscovery({
    @required this.name,
    @required this.discoveries,
  });
}
