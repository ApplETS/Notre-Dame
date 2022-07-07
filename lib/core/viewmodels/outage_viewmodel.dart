import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/views/startup_view.dart';
import 'package:stacked/stacked.dart';

class OutageViewModel extends BaseViewModel {
  int _lastTap = DateTime.now().millisecondsSinceEpoch;
  int _consecutiveTaps = 0;

  double getImagePlacement(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.10;
  }

  double getTextPlacement(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.20;
  }

  double getContactTextPlacement(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.04;
  }

  void triggerTap(BuildContext context) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTap < 1000) {
      _consecutiveTaps++;
      if (_consecutiveTaps > 4) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StartUpView()),
        );
      }
    } else {
      _consecutiveTaps = 1;
    }
    _lastTap = now;
  }
}
