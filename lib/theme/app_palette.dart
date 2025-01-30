import 'package:flutter/material.dart';

abstract class AppPalette {
  static const Color etsLightRed = Color(0xffef3e45);
  static const Color etsDarkRed = Color(0xffbf311a);
  static const Color appletsPurple = Color(0xff19375f);

  static const Color gradeFailureMin = Color(0xffd32f2f);
  static const Color gradeFailureMax = Color(0xffff7043);
  static const Color gradePassing = Color(0xfffff176);
  static const Color gradeGoodMin = Color(0xffaed581);
  static const Color gradeGoodMax = Color(0xff43a047);

  static const grey = _GreyColors();
}

class _GreyColors {
  const _GreyColors();

  final Color lightGrey = const Color(0xff807f83);
  final Color darkGrey = const Color(0xff636467);
  final Color black = const Color(0xff2e2a25);
}