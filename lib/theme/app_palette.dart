import 'package:flutter/material.dart';

abstract class AppPalette {
  static const Color etsLightRed = Color(0xffef3e45);
  static const Color etsDarkRed = Color(0xffbf311a);

  static const grey = _GreyColors();
}

class _GreyColors {
  const _GreyColors();

  final Color lightGrey = const Color(0xff807f83);
  final Color darkGrey = const Color(0xff636467);
  final Color black = const Color(0xff2e2a25);
}