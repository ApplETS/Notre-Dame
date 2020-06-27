
import 'package:flutter/material.dart';
import 'package:notredame/core/services/navigation_service.dart';

import '../../locator.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: RaisedButton(onPressed: () => locator<NavigationService>().pushNamed("/dflsdf"))),
  );
}